<#
.SYNOPSIS 
    Removes a build property

.PARAMETER NAme <string>
    The build property's name

.OUTPUTS
    None
#>
function script:Remove-BuildProperty {
    param([Parameter(Mandatory=$true)][string[]]$Name)

    $Name | ForEach { 
        Remove-Variable -Name $_ -Scope Script -Force
        ${!BuildProperties!}.Remove($_)
        ${script:!BuildProperties!} = ${!BuildProperties!}
    }
}

<#
.SYNOPSIS 
    Marks a file as imported

.PARAMETER FullName <string>
    The file full name

.OUTPUTS
    None
#>
function script:Add-File {
    param([Parameter(Mandatory=$true)][string[]]$FullName)

    $FullName | ForEach { 
        ${!Files!}.Add($_)
        ${script:!Files!} = ${!Files!}
    }
}

<#
.SYNOPSIS 
    Removes an imported file

.PARAMETER FullName <string>
    The file full name

.OUTPUTS
    None
#>
function script:Remove-File {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({ @( $_ | Where { [System.IO.Path]::IsPathRooted($_) -and $_ -match ".*\.(ps1)$" -and (Test-Path $_) } ).Count })]
        [string[]]$FullName
    )

    $FullName | ForEach { 
        ${!Files!}.Remove($_)
        ${script:!Files!} = ${!Files!}
    }
}

<#
.SYNOPSIS
   Installs Pask package found in $BuildOutputFullPath into a target solution

.PARAMETER Version <string> = 0.1.0
   Pask package version

.PARAMETER SolutionFullPath <string>
   The target solution's directory

.OUTPUTS
   None
#>
function script:Install-Pask {
    param(
        [string]$Version = "0.1.0",
        [string]$SolutionFullPath
    )

    $InstallDir = Get-PackagesDir
    $PackageFullPath = (Join-Path $InstallDir "Pask.$Version")

    Install-NuGetPackage -Name "Pask" -Version $Version -InstallDir $InstallDir

    Exec { Robocopy "$(Join-Path $PackageFullPath "scripts")" "$(Join-Path $SolutionFullPath ".build\scripts")" "Pask.ps1" /256 /XO /NP /NFL /NDL /NJH /NJS } (0..7)
    Exec { Robocopy "$(Join-Path $PackageFullPath "init")" "$SolutionFullPath" "Pask.ps1" /256 /XO /NP /NFL /NDL /NJH /NJS } (0..7)
    Exec { Robocopy "$(Split-Path (Get-NuGetExe))" "$(Join-Path $SolutionFullPath ".nuget")" "NuGet.exe" /256 /XO /NP /NFL /NDL /NJH /NJS } (0..7)
}