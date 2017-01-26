# Synopsis: Create the artifact by copying MSBuild output to the build output directory
Task New-Artifact {
    Import-Properties -Package Pask

    New-Directory $BuildOutputFullPath | Out-Null

    "Creating artifact in $ArtifactFullPath"

    # This is either the location of the web deploy package or a web application
    $WebApplicationOutputFullPath = Join-Path $ProjectFullPath $WebApplicationOutputPath

    # Web deployment package temp output (from which the web deployment package was created)
    $WebDeployPackageOutputFullPath = Join-Path (Join-Path $ProjectFullPath "obj") "$BuildPlatform\$BuildConfiguration\Package\PackageTmp"

    if ((Test-Path (Join-Path $WebApplicationOutputFullPath "$ProjectName.zip")) -and (Test-Path $WebDeployPackageOutputFullPath) ) {
        # A web deployment package was created via Build-WebDeployPackage task
        # Copy the zip web deployment package into the artifact directory
        Exec { Robocopy "$WebApplicationOutputFullPath" "$BuildOutputFullPath" "$ProjectName.zip" /256 /XO /NP /NFL /NDL /NJH /NJS } (0..7)
        # Rename the zip web package to include the version
        Move-Item (Join-Path $BuildOutputFullPath "$ProjectName.zip") (Join-Path $BuildOutputFullPath "$ProjectName.$($Version.InformationalVersion).zip") -Force
        # Copy the web application artifact
        Exec { Robocopy "$WebDeployPackageOutputFullPath" "$ArtifactFullPath" /256 /MIR /XO /NP /NFL /NDL /NJH /NJS } (0..7)
    } elseif (Test-Path $WebApplicationOutputFullPath) {
        # A web application was built via Build-WebApplication task
        Exec { Robocopy "$WebApplicationOutputFullPath" "$ArtifactFullPath" /256 /MIR /XO /NP /NFL /NDL /NJH /NJS } (0..7)
    } else {
        $BuildOutputFullPath = Get-ProjectBuildOutputDir $ProjectName
        Exec { Robocopy "$BuildOutputFullPath" "$ArtifactFullPath" /256 /MIR /XO /NP /NFL /NDL /NJH /NJS } (0..7)
    }

    if ($RemoveArtifactPDB -eq $true) {
        Remove-PdbFiles $ArtifactFullPath
    }
}