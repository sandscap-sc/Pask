Set-Property Version -Default (Get-Version)

# Test-Pester
Set-Property TestName -Default ""

# Push-Local task
Set-Property LocalNuGetFeed -Default "C:\LocalNuGetFeed"

# MSBuild tasks
Set-Property BuildProjectOnly -Default $false
Set-Property BuildConfiguration -Default "Debug"
Set-Property MSBuildVersion -Default "14.0"
Set-Property BuildPlatform -Default ""
Set-Property WebApplicationOutputPath -Default "obj/WebOut"
