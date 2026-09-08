$path = 'd:\bdapps Gladiators - NADB26\Sheba Bondhu\sheba_bondhu\lib\screens\home_screen.dart'
$lines = Get-Content $path
$kept = @()
$skip = $false
foreach ($line in $lines) {
    if ($line -match 'floatingActionButton: FloatingActionButton\.extended\(') {
        $skip = $true
        continue
    }
    if ($skip) {
        if ($line -match '^\s*\),$') {
            $skip = $false
        }
        continue
    }
    $kept += $line
}
$kept | Out-File -FilePath $path -Encoding utf8 -NoNewline
Write-Output "FAB removed, new length: $((Get-Item $path).Length)"