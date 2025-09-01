function New-PSMsSPOUploadSession {
    <#
    .SYNOPSIS
        Creates a Microsoft Graph upload session.

    .DESCRIPTION
        Calls POST ...:/createUploadSession with the supplied body and returns the session object.
        The response includes 'uploadUrl' and other session metadata.

    .PARAMETER Service
        Entra service name configured for Invoke-EntraRequest.

    .PARAMETER CreatePath
        Relative Graph path ending with :/createUploadSession.

    .PARAMETER Body
        Request payload produced by New-PSMsSPOUploadSessionBody.

    .OUTPUTS
        System.Object
        (Upload session descriptor as returned by Graph.)

    .EXAMPLE
        $session = New-PSMsSPOUploadSession -Service $service -CreatePath $createPath -Body $body
        $uploadUrl = $session.uploadUrl
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)
        ][string] $Service,
        [Parameter(Mandatory)]
        [string] $CreatePath,
        [Parameter(Mandatory)]
        [hashtable] $Body
    )
    Invoke-EntraRequest -Service $Service -Path $CreatePath -Method Post -Body $Body -ErrorAction Stop
}
