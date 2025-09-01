function Send-PSMsSPOFile {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    <#
    .SYNOPSIS
        Upload a local file to SharePoint Online / Teams via Microsoft Graph.

    .DESCRIPTION
        Supports small uploads (PUT, <= 4 MB) and large uploads via upload session (chunked)
        when -UseUploadSession is specified or when the file exceeds 4 MB.
        The destination can be referenced by drive-root relative path (-FolderPath) or by parent item Id (-ParentItemId).

        For small PUT uploads, this cmdlet uses New-PSMsSPOUploadPayload to autodetect text vs. binary
        based on the actual file content (strict UTF-8 for text), then delegates to Invoke-PSMsSPOSmallUpload.

    .PARAMETER DriveId
        Target drive identifier.

    .PARAMETER FolderPath
        (Path) Target folder path relative to drive root (no '/drive/root:' prefix).

    .PARAMETER ParentItemId
        (Id) Target parent folder item Id.

    .PARAMETER FilePath
        Local file to upload.

    .PARAMETER ConflictBehavior
        Conflict handling for create/overwrite: replace (default), rename, or fail.

    .PARAMETER ETag
        Optional If-Match for small PUT uploads.

    .PARAMETER UseUploadSession
        Force upload session (also automatically used for files > 4 MB).

    .PARAMETER ChunkSizeMB
        Chunk size used for upload session. Default: 8 MB.

    .PARAMETER EnableException
        Enables terminating exceptions (instead of user-friendly warnings).

    .PARAMETER PassThru
        For small PUT, returns a batch request object instead of executing.

    .EXAMPLE
        Send-PSMsSPOFile -DriveId $drive.Id -FolderPath 'Documents/Specs' -FilePath 'C:\Temp\design.docx'

    .EXAMPLE
        Send-PSMsSPOFile -DriveId $drive.Id -ParentItemId $folder.Id -FilePath 'C:\Temp\video.mp4' -UseUploadSession
    #>
    [OutputType('PSMsSPO.DriveItem')]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Path')]
    param(
        # Shared
        [Parameter(ParameterSetName = 'Path', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Id', Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $DriveId,
        [Parameter(ParameterSetName = 'Path', Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $FolderPath,
        [Parameter(ParameterSetName = 'Id', Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ParentItemId,
        [Parameter(ParameterSetName = 'Path', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Id', Mandatory = $true)]
        [ValidateFileExistsAttribute()]
        [string] $FilePath,
        [Parameter()][ValidateSet('replace', 'rename', 'fail')]
        [string] $ConflictBehavior = 'replace',
        [Parameter()]
        [string] $ETag,
        [Parameter()] [switch]
        $UseUploadSession,
        [Parameter()][ValidateRange(1, 256)]
        [int] $ChunkSizeMB = 8,
        [Parameter()] [switch] $EnableException,
        [Parameter()] [switch] $PassThru
    )

    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        [hashtable] $header = @{
            'Content-Type' = 'application/json'
        }
        [hashtable] $body = @{}
        if ($Force.IsPresent -and (-not $Confirm.IsPresent)) {
            [bool] $cmdLetConfirm = $false
        }
        else {
            [bool] $cmdLetConfirm = $true
        }
    }

    process {
        [string] $absoluteFilePath = (Resolve-Path -LiteralPath $FilePath).Path
        [string] $fileName = [System.IO.Path]::GetFileName($absoluteFilePath)
        [byte[]] $bytes = [System.IO.File]::ReadAllBytes($absoluteFilePath)
        [long] $sizeBytes = $bytes.LongLength

        switch ($PSCmdlet.ParameterSetName) {

            'Path' {
                [string] $path = Get-PSMsSPOPutPathByPath -DriveId $DriveId -FolderPath $FolderPath -FileName $fileName -ConflictBehavior $ConflictBehavior

                if ($PassThru.IsPresent -and -not ($UseUploadSession.IsPresent -or $sizeBytes -gt 4MB)) {
                    [hashtable] $payload = New-PSMsSPOUploadPayload -Bytes $bytes -ETag $ETag
                    [PSMicrosoftEntraID.Batch.Request] @{
                        Method  = 'PUT'
                        Url     = ('/{0}' -f $path)
                        Body    = $payload.Body
                        Headers = $payload.Headers
                    }
                    return
                }

                if ($PSCmdlet.ShouldProcess(("drives/{0}" -f $DriveId), ("Upload '{0}' to '{1}'" -f $fileName, $FolderPath))) {
                    if ($UseUploadSession.IsPresent -or $sizeBytes -gt 4MB) {
                        [string] $create = $path -replace ':/content\?[^$]+$', ':/createUploadSession'
                        [hashtable] $body = New-PSMsSPOUploadSessionBody -FileName $fileName -ConflictBehavior $ConflictBehavior
                        Invoke-PSFProtectedCommand -ActionString 'DriveItem.Upload' -ActionStringValues $fileName -Target $DriveId -ScriptBlock {
                            [string] $url = (New-PSMsSPOUploadSession -Service $service -CreatePath $create -Body $body).uploadUrl
                            ConvertFrom-RestDriveItem -InputObject (Invoke-PSMsSPOChunkedUpload -Service $service -UploadUrl $url -Content $bytes -ChunkSizeMB $ChunkSizeMB)
                        } -EnableException:$EnableException -Confirm:$false -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    }
                    else {
                        [hashtable] $payload = New-PSMsSPOUploadPayload -Bytes $bytes -ETag $ETag
                        Invoke-PSFProtectedCommand -ActionString 'DriveItem.Upload' -ActionStringValues $fileName -Target $DriveId -ScriptBlock {
                            if ($payload.IsText) {
                                ConvertFrom-RestDriveItem -InputObject (Invoke-PSMsSPOSmallUpload -Service $service -Path $path -TextContent $payload.Body -Encoding ([Text.Encoding]::UTF8) -ContentType $payload.Headers['Content-Type'] -ETag $ETag)
                            }
                            else {
                                ConvertFrom-RestDriveItem -InputObject (Invoke-PSMsSPOSmallUpload -Service $service -Path $path -Content $payload.Body -ETag $ETag)
                            }
                        } -EnableException:$EnableException -Confirm:$false -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    }
                }
            }
            'Id' {
                [string] $path = Get-PSMsSPOPutPathById -DriveId $DriveId -ParentItemId $ParentItemId -FileName $fileName -ConflictBehavior $ConflictBehavior
                if ($PassThru.IsPresent -and -not ($UseUploadSession.IsPresent -or $sizeBytes -gt 4MB)) {
                    [hashtable] $payload = New-PSMsSPOUploadPayload -Bytes $bytes -ETag $ETag
                    [PSMicrosoftEntraID.Batch.Request] @{
                        Method  = 'PUT'
                        Url     = ('/{0}' -f $path)
                        Body    = $payload.Body
                        Headers = $payload.Headers
                    }
                    return
                }

                if ($PSCmdlet.ShouldProcess(("drives/{0}" -f $DriveId), ("Upload '{0}' to parentId '{1}'" -f $fileName, $ParentItemId))) {
                    if ($UseUploadSession.IsPresent -or $sizeBytes -gt 4MB) {
                        [string] $create = $path -replace ':/content\?[^$]+$', ':/createUploadSession'
                        [hashtable] $body = New-PSMsSPOUploadSessionBody -FileName $fileName -ConflictBehavior $ConflictBehavior
                        Invoke-PSFProtectedCommand -ActionString 'DriveItem.Upload' -ActionStringValues $fileName -Target $DriveId -ScriptBlock {
                            [string] $url = (New-PSMsSPOUploadSession -Service $service -CreatePath $create -Body $body).uploadUrl
                            ConvertFrom-RestDriveItem -InputObject (Invoke-PSMsSPOChunkedUpload -Service $service -UploadUrl $url -Content $bytes -ChunkSizeMB $ChunkSizeMB)
                        } -EnableException:$EnableException -Confirm:$false -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    }
                    else {
                        [hashtable] $payload = New-PSMsSPOUploadPayload -Bytes $bytes -ETag $ETag
                        Invoke-PSFProtectedCommand -ActionString 'DriveItem.Upload' -ActionStringValues $fileName -Target $DriveId -ScriptBlock {
                            if ($payload.IsText) {
                                ConvertFrom-RestDriveItem -InputObject (Invoke-PSMsSPOSmallUpload -Service $service -Path $path -TextContent $payload.Body -Encoding ([Text.Encoding]::UTF8) -ContentType $payload.Headers['Content-Type'] -ETag $ETag)
                            }
                            else {
                                ConvertFrom-RestDriveItem -InputObject (Invoke-PSMsSPOSmallUpload -Service $service -Path $path -Content $payload.Body -ETag $ETag)
                            }
                        } -EnableException:$EnableException -Confirm:$false -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    }
                }
            }
        }
    }

    end {}
}
