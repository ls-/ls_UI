Set-Location $PSScriptRoot

if (-not (Test-Path "C:\PROGRA~1\7-Zip\7z.exe")) {
	throw "7z.exe not found"
}

Set-Alias 7z "C:\PROGRA~1\7-Zip\7z.exe"

$addonName = (Get-Item .).Name

if (-not (Test-Path (".\" + $addonName + ".toc"))) {
	throw ".toc not found"
}

$curVersion = if ((Get-Content (".\" + $addonName + ".toc") | Where { $_ -match "Version: ([0-9]+\.[0-9]+)" } ) -match "([0-9]+\.[0-9]+)") {$matches[1]}

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

if (Test-Path ".\temp\") {
	Remove-Item ".\temp\" -Recurse -Force
}

New-Item -Path (".\temp\" + $addonName) -ItemType Directory
Copy-Item "..\!includes\oUF_LS\" -Destination ".\temp" -Recurse
Copy-Item $includedFiles -Destination (".\temp\" + $addonName) -Recurse
Remove-Item ".\temp" -Include $filesToRemove -Recurse -Force

Set-Location ".\temp\"

7z a -tzip -mx9 ($addonName + "-" + $curVersion + ".zip") (Get-ChildItem -Path "..\temp")

Set-Location "..\"

Move-Item ".\temp\*.zip" -Destination "..\" -Force
Remove-Item ".\temp" -Recurse -Force
