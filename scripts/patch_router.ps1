Set-Location 'd:\bdapps Gladiators - NADB26\Sheba Bondhu\sheba_bondhu'
$router = 'lib\core\routing\app_router.dart'
$c = Get-Content $router -Raw
$c = $c -replace "import 'package:go_router/go_router.dart';", "import 'package:go_router/go_router.dart';`r`n`r`nimport '../../core/theme/app_colors.dart';"
$c | Out-File -FilePath $router -Encoding utf8 -NoNewline
Write-Host "router patched: $((Get-Item $router).Length) bytes"
