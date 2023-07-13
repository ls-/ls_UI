Set-Location $PSScriptRoot

$luacheckrc = ".\.luacheckrc"

$out = ""
foreach ($line in Get-Content $luacheckrc) {
	if ($line -match "read_globals") { break }

	$out += $line + "`n"
}

Set-Content $luacheckrc -Value $out.TrimEnd()

$out = @()
luacheck . | ForEach-Object {
	if ($_ -match "accessing undefined variable '(.+?)'") {
		if ($out -notcontains $matches[1]) {
			$out += $matches[1]
		}
	}
}

Add-Content $luacheckrc ""
Add-Content $luacheckrc ("read_globals = {")

foreach ($arg in $out | Sort-Object) {
	Add-Content $luacheckrc ("`t`"" + $arg + "`",")
}

Add-Content $luacheckrc ("}")
