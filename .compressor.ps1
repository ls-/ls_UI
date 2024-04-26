Set-Location $PSScriptRoot

$name = (Get-Item .).Name

if (-Not (Test-Path (".\" + $name + "\" + $name + ".toc"))) {
	Write-Host ".toc not found"

	return Read-Host
}

if (Get-Content (".\" + $name + "\" + $name + ".toc") | Where-Object { $_ -match "Version:\s*([a-zA-Z0-9.-]+)" }) {
	$version = $matches[1]
} else {
	Write-Host "Bad version format"

	return Read-Host
}

$foldersToInclude = @(
	".\ls_UI\",
	".\ls_UI_Options\"
)

$filesToExclude = @(
	"*.doc*"
	"*.editorconfig",
	"*.git*",
	"*.luacheck*",
	"*.pkg*",
	"*.ps1",
	"*.sh",
	"*.yml"
)

$foldersToRemove = @(
	".github",
	"utils"
)

$temp = ".\temp\"

if (Test-Path $temp) {
	Remove-Item $temp -Recurse -Force
}

New-Item -Path $temp -ItemType Directory | Out-Null
Copy-Item $foldersToInclude -Destination $temp -Exclude $filesToExclude -Recurse
Get-ChildItem $temp -Recurse | Where-Object { $_.PSIsContainer -and $_.Name -cin $foldersToRemove } | Remove-Item -Recurse -Force
Get-ChildItem $temp | Compress-Archive -DestinationPath "..\$name-$version.zip" -Force
Remove-Item $temp -Recurse -Force
