$ErrorActionPreference = 'Stop'
$paths = @(
  'd:\bdapps Gladiators - NADB26\Sheba Bondhu\sheba_bondhu\lib\core\localization\arb\app_en.arb',
  'd:\bdapps Gladiators - NADB26\Sheba Bondhu\sheba_bondhu\lib\core\localization\arb\app_bn.arb'
)
foreach ($p in $paths) {
  Write-Output "==== $p ===="
  $c = Get-Content $p -Raw
  $lines = $c -split "`r?`n"
  Write-Output ("TOTAL_LINES=" + $lines.Count)
  Write-Output '--- LAST 60 ---'
  $tail = $lines | Select-Object -Last 60
  $tail | ForEach-Object { Write-Output $_ }
  Write-Output ''
}
