# Array of specific file names to extract only (e.g. MyAssembly.dll)
Set-Property FileNameToExtract -Default @()

# Synopsis: Extract the artifact from a ZIP archive or a NuGet package
Task Extract-Artifact {
    # Find the ZIP archive or the NuGet package
    $ZipArtifact = Get-ChildItem -Path (Join-Path $BuildOutputFullPath "$ArtifactName.*.zip") | Select -Last 1
    $Package = Get-ChildItem -Path (Join-Path $BuildOutputFullPath "$ArtifactName.*.nupkg") | Select -Last 1

    Assert (($ZipArtifact -and (Test-Path $ZipArtifact)) -or ($Package -and (Test-Path $Package))) "Cannot not find the ZIP/NuGet artifact"

    $7za = Join-Path (Get-PackageDir "7-Zip.CommandLine") "tools\7za.exe"
	
    # Remove and re-create the artifact directory
    Remove-PaskItem $ArtifactFullPath
    New-Directory $ArtifactFullPath | Out-Null
	
    if ($ZipArtifact) {
        "Extracting artifact $($ZipArtifact.Name)"
        Exec { & "$7za" x ("{0}" -f $ZipArtifact.FullName) "-o$ArtifactFullPath" $FileNameToExtract -r -y | Out-Null }
    } elseif ($Package) {
        "Extracting package '$($Package.Name)'"
        Exec { & "$7za" e ("{0}" -f $Package.FullName) "-o$ArtifactFullPath" $FileNameToExtract -r -y | Out-Null }
    }
}