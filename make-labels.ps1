#Requires -Modules @{ ModuleName = "PSDKit"; ModuleVersion = "0.6.2"}
#Requires -Modules @{ ModuleName = "PowerGit"; ModuleVersion = "0.9.0"}
#Requires -Modules @{ ModuleName = "PSGitHub"; ModuleVersion = "0.15.240"}

param(
    [string]$ConfigFile = "$PSScriptRoot\label.config.psd1",
    [switch]$KeepDefaults
)

if (-not($KeepDefaults)) {
    $repo = Get-GitRepository | Select-Object -ExpandProperty RepositoryName
    Write-Host "Removing existing labels from $repo" -ForegroundColor DarkGray
    Get-GitHubLabel -RepositoryName $repo | Foreach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor DarkGray -NoNewline
        try {
            Remove-GitHubLabel -RepositoryName $repo -Name $_.Name -Force
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
        Write-Host "    `u{f42e}" -ForegroundColor DarkGreen
    }
}


$config = Import-Psd $ConfigFile

Write-Host
Write-Host "Adding new labels from $ConfigFile" -ForegroundColor DarkGray
foreach ($label in $config.labels) {
    Write-Host "  - $($label.Name)" -ForegroundColor DarkGray -NoNewline
    try {
        Get-GitRepository | New-GitHubLabel @label
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    Write-Host "    `u{f42e}" -ForegroundColor DarkGreen
}
