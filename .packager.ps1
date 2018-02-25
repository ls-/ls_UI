Set-Location $PSScriptRoot

if (-Not (Test-Path "C:\PROGRA~1\7-Zip\7z.exe")) {
	Write-Host "7z.exe not found"

	return Read-Host
}

Set-Alias 7z "C:\PROGRA~1\7-Zip\7z.exe"

$name = (Get-Item .).Name

if (-Not (Test-Path (".\" + $name + ".toc"))) {
	Write-Host ".toc not found"

	return Read-Host
}

if (Get-Content (".\" + $name + ".toc") | Where-Object { $_ -match "(Version: +)([a-zA-Z0-9.-]+)" }) {
	$version = $matches[2]
} else {
	Write-Host "Bad version format"

	return Read-Host
}

$includedItems = @(
	".\init.lua",
	".\LICENSE.txt",
	".\ls_UI.toc",
	".\assets\",
	".\config\",
	".\core\",
	".\embeds\",
	".\locales\",
	".\modules\"
)

$filesToRemove = @(
	"*.git*",
	"*.pkg*",
	"*.ps1",
	"*.yml",
	"CHANGELOG*",
	"README*"
)

$foldersToRemove = @(
	".\temp\ls_UI\embeds\oUF\utils"
)

if (Test-Path ".\temp\") {
	Remove-Item ".\temp\" -Recurse -Force
}

New-Item -Path (".\temp\" + $name) -ItemType Directory | Out-Null
Copy-Item $includedItems -Destination (".\temp\" + $name) -Recurse
Remove-Item ".\temp" -Include $filesToRemove -Recurse -Force
Remove-Item $foldersToRemove -Recurse -Force

Set-Location ".\temp\"

7z a -tzip -mx9 ($name + "-" + $version + ".zip") (Get-ChildItem -Path "..\temp")

Set-Location "..\"

Move-Item ".\temp\*.zip" -Destination "..\" -Force
Remove-Item ".\temp" -Recurse -Force
