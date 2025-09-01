try {
    $alreadyLoaded = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object {
        $_.GetName().Name -eq 'PSMicrosoftEntraID'
    }
    if (-not $alreadyLoaded) {
        Add-Type -Path "$script:ModuleRoot\bin\PSMicrosoftEntraID.dll" -ErrorAction Stop
    }
    Add-Type -Path "$script:ModuleRoot\bin\PSMicrosoftSharepointOnline.dll" -ErrorAction Stop
}
catch {
    Write-Warning "Failed to load PSMicrosoftEntraID Assembly! Unable to import module."
    throw
}
try {
    #Update-TypeData -AppendPath "$script:ModuleRoot\types\PSMicrosoftSharepointOnline.Types.ps1xml" -ErrorAction Stop
}
catch {
    Write-Warning "Failed to load PSMicrosoftSharepointOnline type extensions! Unable to import module."
    throw
}