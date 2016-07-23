Set-Location $PSScriptRoot

$curVersion = if ((Get-Content ".\ls_UI.toc" | Where { $_ -match "Version: ([0-9]+\.[0-9]+)" } ) -match "([0-9]+\.[0-9]+)") {$matches[1]}
$folderName = "ls_UI"
$zipName = $folderName + "-" + $curVersion + ".zip"

$includedFiles = @(
	".\init.lua",
	".\ls_UI.toc",
	".\LICENSE.txt",
	".\config\",
	".\core\",
	".\embeds\",
	".\locales\",
	".\media\",
	".\modules\"
)

$filesToRemove = @(
	".git",
	".packager.ps1",
	"CHANGELOG*",
	"README*"
)

Remove-Item * -Include @("*.zip", $folderName) -Recurse -Force

New-Item -Name $folderName -ItemType Directory | Out-Null
Copy-Item $includedFiles -Destination $folderName -Recurse
Remove-Item $folderName -Include $filesToRemove -Recurse -Force
Compress-Archive -Path $folderName -DestinationPath $zipName
Move-Item ".\ls_UI-*.zip" -Destination "..\" -Force

Remove-Item $folderName -Recurse -Force
