Set-Location $PSScriptRoot

if (-Not (Test-Path "$env:ProgramFiles\7-Zip\7z.exe")) {
	Write-Host "7z.exe not found"

	return Read-Host
}

Set-Alias 7z "$env:ProgramFiles\7-Zip\7z.exe"

function Remove-Kaka([Parameter(Mandatory, ValueFromPipeline)] $file) {
	process {
		$canWrite = $true
		$out = ""

		foreach ($line in Get-Content $file ) {
			if ($line -match "--@do-not-package@") {
				$canWrite = $false
			}
			elseif ($line -match "--@end-do-not-package@" ) {
				$canWrite = $true

				if (-not $foreach.MoveNext()) {
					break
				}

				$line = $foreach.Current
			}

			if ($canWrite) {
				$out += "$line`n"
			}
		}

		Set-Content $file -Value $out.TrimEnd()
	}
}

$name = (Get-Item .).Name

if (-Not (Test-Path (".\$name\$name.toc"))) {
	Write-Host ".toc not found"

	return Read-Host
}

if (Get-Content (".\$name\$name.toc") | Where-Object { $_ -match "Version:\s*([a-zA-Z0-9.-]+)" }) {
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
Get-ChildItem $temp -Recurse | Where-Object { $_.Extension -eq ".lua"} | Remove-Kaka
7z a -tzip -mx9 "..\$name-$version.zip" (Get-ChildItem $temp)
Remove-Item $temp -Recurse -Force
