Set-Location $PSScriptRoot

$curVersion = if ((Get-Content ".\oUF_LS.toc" | Where { $_ -match "Version: ([0-9]+\.[0-9]+)" } ) -match "([0-9]+\.[0-9]+)") {$matches[1]}
$folderName = "oUF_LS"
$zipName = $folderName + "-" + $curVersion + ".zip"

$includedFiles = @(
	".\init.lua",
	".\oUF_LS.toc",
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
	"README.md"
)

Remove-Item * -Include @("*.zip", $folderName) -Recurse -Force

New-Item -Name $folderName -ItemType Directory | Out-Null
Copy-Item $includedFiles -Destination $folderName -Recurse
Remove-Item $folderName -Include $filesToRemove -Recurse -Force
Compress-Archive -Path $folderName -DestinationPath $zipName
Move-Item ".\oUF_LS-*.zip" -Destination "..\" -Force

Remove-Item $folderName -Recurse -Force
