# Synopsis: Apply the current version to the build server
Task Version-BuildServer {
    Import-Properties -Project Pask

    if ($env:TEAMCITY_VERSION) {
        "##teamcity[buildNumber '$($Version.InformationalVersion)']"
    } elseif ($env:TF_BUILD) {
        "##vso[build.updatebuildnumber]$($Version.InformationalVersion)"
    } elseif($env:APPVEYOR) {
        $Uri = [System.IO.Path]::Combine($env:APPVEYOR_API_URL, "api\build").Replace('\', '/')
        $Data = "{ `"version`": `"$($Version.InformationalVersion)`" }"
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
        $Response = Invoke-WebRequest -Uri $Uri -Method Put -ContentType "application/json" -Body $Bytes
    }
}