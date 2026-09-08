$ErrorActionPreference = 'Stop'
Set-Location 'd:\bdapps Gladiators - NADB26\Sheba Bondhu\sheba_bondhu'

$path = 'lib\screens\home_screen.dart'
$orig = Get-Content $path -Raw

$pattern = '(?ms)      floatingActionButton: FloatingActionButton\.extended\(\r?\n        onPressed: \(\) => context\.push\(''/money/edit''\),\r?\n        backgroundColor: AppColors\.brandGreen,\r?\n        foregroundColor: AppColors\.white,\r?\n        icon: const Icon\(Icons\.add\),\r?\n        label: Text\(l10n\.moreMoneyTitle\),\r?\n        tooltip: l10n\.homeQuickAddMoneyTooltip,\r?\n      \),\r?\n'

$new = [regex]::Replace($orig, $pattern, '')
$new | Out-File -FilePath $path -Encoding utf8 -NoNewline

$len = (Get-Item $path).Length
Write-Output "length_after=$len"
Write-Output "contains_fab=$($new.Contains('FloatingActionButton'))"