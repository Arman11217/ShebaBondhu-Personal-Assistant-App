# Fix all remaining broken imports left by the MSS migration.
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$lib  = Join-Path $root "lib"

function Fix-File($path, $pairs) {
    $txt = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    $orig = $txt
    foreach ($p in $pairs) {
        $txt = $txt.Replace($p[0], $p[1])
    }
    if ($txt -ne $orig) {
        Set-Content -LiteralPath $path -Value $txt -Encoding UTF8 -NoNewline
        Write-Host "  fixed: $path"
    }
}

$screensPairs = @(
    "import 'core/constants/",            "import '../core/constants/",
    "import 'core/errors/",               "import '../core/errors/",
    "import 'core/localization/",         "import '../core/localization/",
    "import 'core/network/",              "import '../core/network/",
    "import 'core/storage/",              "import '../core/storage/",
    "import 'core/theme/",                "import '../core/theme/",
    "import 'core/widgets/",              "import '../widgets/"
)
Get-ChildItem -Path (Join-Path $lib "screens") -Filter "*.dart" | ForEach-Object {
    Fix-File $_.FullName (, $screensPairs)
}

$widgetsPairs = @(
    "import '../theme/",         "import '../core/theme/",
    "import '../localization/",  "import '../core/localization/",
    "import '../constants/",     "import '../core/constants/"
)
Get-ChildItem -Path (Join-Path $lib "widgets") -Filter "*.dart" | ForEach-Object {
    Fix-File $_.FullName (, $widgetsPairs)
}

$router = Join-Path $lib "routing/app_router.dart"
$routerPairs = @(
    "'../features/auth/presentation/pages/login_screen.dart'",      "'../screens/login_screen.dart'",
    "'../features/auth/presentation/pages/otp_screen.dart'",        "'../screens/otp_screen.dart'",
    "'../features/home/presentation/pages/home_screen.dart'",       "'../screens/home_shell_screen.dart'",
    "'../features/onboarding/presentation/pages/language_select_screen.dart'","'../screens/language_select_screen.dart'",
    "'../features/onboarding/presentation/pages/onboarding_screen.dart'","'../screens/onboarding_screen.dart'",
    "'../features/onboarding/presentation/pages/splash_screen.dart'","'../screens/splash_screen.dart'"
)
Fix-File $router (, $routerPairs)

Write-Host "`nAll import fixes applied."
