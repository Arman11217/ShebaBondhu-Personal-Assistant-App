$path = 'd:\bdapps Gladiators - NADB26\Sheba Bondhu\sheba_bondhu\lib\core\routing\app_router.dart'
$c = Get-Content $path -Raw
$old = "          GoRoute(path: '/more', builder: (_, _) => const MoreScreen()),"
$new = "          GoRoute(path: '/more', builder: (_, _) => MoreScreen(geminiService: geminiService)),"
$c = $c.Replace($old, $new)
$c | Out-File -FilePath $path -Encoding utf8 -NoNewline
$len = (Get-Item $path).Length
Write-Output "router updated: $len bytes; const removed=$($c.Contains('const MoreScreen'))"