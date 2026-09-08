# migrate_to_mss.ps1
# SHEBA BONDHU — Convert Clean Architecture layout to MSS (Model + Service + Screen).
# Idempotent: run twice safely (skips already-migrated files).
#
# Layout target:
#   lib/main.dart                 (unchanged)
#   lib/app.dart                  (unchanged)
#   lib/core/...                  (unchanged)
#   lib/routing/app_router.dart   (unchanged, imports rewritten)
#   lib/models/<x>.dart           (new — domain entities go here later)
#   lib/services/<x>_service.dart (new — business logic + API + providers)
#   lib/screens/<x>_screen.dart   (new — UI)
#   lib/widgets/<x>.dart          (new — reusable UI bits)

[CmdletBinding()]
param(
    [switch]$DryRun = $false
)

$ErrorActionPreference = 'Stop'
$root       = Resolve-Path "$PSScriptRoot\.."
$lib        = Join-Path $root 'lib'
$features   = Join-Path $lib 'features'
$coreW      = Join-Path $lib 'core\widgets'
$models     = Join-Path $lib 'models'
$services   = Join-Path $lib 'services'
$screens    = Join-Path $lib 'screens'
$widgets    = Join-Path $lib 'widgets'

function Log($msg, $color = 'Cyan') { Write-Host $msg -ForegroundColor $color }

function Ensure-Dir($p) {
    if (-not (Test-Path $p)) {
        if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $p | Out-Null }
        Log "  + dir $p"
    }
}

function Move-File($src, $dst) {
    if (-not (Test-Path $src)) { return }
    if (Test-Path $dst) {
        Log "  = skip (exists) $dst"
        return
    }
    if (-not $DryRun) { Move-Item -Force -Path $src -Destination $dst }
    Log "  -> $dst"
}

function Rewrite-Imports {
    # Find every .dart file under lib/ (skip generated/) and rewrite imports.
    Get-ChildItem -Recurse -File -Filter '*.dart' -Path $lib |
        Where-Object { $_.FullName -notmatch '[/\\]generated[/\\]' } |
        ForEach-Object {
            $file = $_.FullName
            $text = [System.IO.File]::ReadAllText($file)

            $orig = $text
            # 1) Old feature paths -> new top-level paths
            $text = $text -replace "'\.\./\.\./\.\./\.\./(core/|models/|services/|screens/|widgets/)", "'../../`$1"
            $text = $text -replace "'\.\./\.\./\.\./(core/|models/|services/|screens/|widgets/)", "'../`$1"
            $text = $text -replace "'\.\./\.\./(core/|models/|services/|screens/|widgets/)", "'`$1"

            # 2) Any leftover '../../core/' -> '../core/' (we're now 1 level shallower)
            $text = $text -replace "'\.\./\.\./core/", "'../core/"
            $text = $text -replace "'\.\./core/", "'../core/"

            # 3) Renamed symbol references that map to new file names
            $text = $text -replace 'home_shell_page\.dart', 'home_screen.dart'
            $text = $text -replace 'language_select_page\.dart', 'language_select_screen.dart'
            $text = $text -replace 'onboarding_page\.dart', 'onboarding_screen.dart'
            $text = $text -replace 'splash_page\.dart', 'splash_screen.dart'
            $text = $text -replace 'login_page\.dart', 'login_screen.dart'
            $text = $text -replace 'otp_page\.dart', 'otp_screen.dart'
            $text = $text -replace 'app_bottom_nav\.dart', 'app_bottom_nav.dart'
            $text = $text -replace 'app_card\.dart', 'app_card.dart'
            $text = $text -replace 'status_states\.dart', 'status_states.dart'

            # 4) Class renames: *Page -> *Screen (Flutter convention; matches filenames)
            $text = $text -replace '\bSplashPage\b',          'SplashScreen'
            $text = $text -replace '\bLanguageSelectPage\b',   'LanguageSelectScreen'
            $text = $text -replace '\bOnboardingPage\b',       'OnboardingScreen'
            $text = $text -replace '\bLoginPage\b',            'LoginScreen'
            $text = $text -replace '\bOtpPage\b',              'OtpScreen'
            $text = $text -replace '\bHomeShellPage\b',        'HomeShellScreen'

            if ($text -ne $orig) {
                if (-not $DryRun) { [System.IO.File]::WriteAllText($file, $text, [System.Text.UTF8Encoding]::new($false)) }
                Log "  ~ rewrote $(Resolve-Path -Relative $file)"
            }
        }
}

# ---------------------------------------------------------------------------
Log '=== Phase 1: create target folders ===' 'Yellow'
Ensure-Dir $models
Ensure-Dir $services
Ensure-Dir $screens
Ensure-Dir $widgets

# ---------------------------------------------------------------------------
Log '=== Phase 2: move files ===' 'Yellow'

# screens/ — every *_page.dart under features/<x>/presentation/pages/
Get-ChildItem -Recurse -File -Filter '*_page.dart' -Path $features | ForEach-Object {
    $name    = $_.Name -replace '_page\.dart$', '_screen.dart'
    $dst     = Join-Path $screens $name
    Move-File $_.FullName $dst
}

# services/ — *_repository.dart, *_service.dart, *_provider.dart, *_use_case.dart
# (no files yet in this project, but the rule is here for future migrations)
$serviceGlobs = @('*_repository.dart','*_service.dart','*_provider.dart','*_use_case.dart')
foreach ($pattern in $serviceGlobs) {
    Get-ChildItem -Recurse -File -Filter $pattern -Path $features -ErrorAction SilentlyContinue | ForEach-Object {
        $dst = Join-Path $services $_.Name
        Move-File $_.FullName $dst
    }
}

# models/ — anything left under features/<x>/domain/ plus entities/ root
$modelGlobs = @('*_entity.dart','*_model.dart','*.dart')
Get-ChildItem -Recurse -File -Path $features -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.FullName -match '[/\\]domain[/\\]') {
        $dst = Join-Path $models $_.Name
        Move-File $_.FullName $dst
    }
}

# widgets/ — core/widgets/<x>.dart moves up
Get-ChildItem -File -Filter '*.dart' -Path $coreW | ForEach-Object {
    $dst = Join-Path $widgets $_.Name
    Move-File $_.FullName $dst
}

# ---------------------------------------------------------------------------
Log '=== Phase 3: rewrite imports in remaining lib/ files ===' 'Yellow'
Rewrite-Imports

# ---------------------------------------------------------------------------
Log '=== Phase 4: drop now-empty feature folders ===' 'Yellow'
if (Test-Path $features) {
    if (-not $DryRun) {
        # Remove deepest first
        Get-ChildItem -Recurse -Directory -Path $features |
            Sort-Object { $_.FullName.Length } -Descending |
            ForEach-Object {
                if (-not (Get-ChildItem -Force -Path $_.FullName | Where-Object { -not $_.PSIsContainer })) {
                    Remove-Item -Recurse -Force $_.FullName
                }
            }
    }
    Log "  - cleaned $features"
}

if ((Test-Path $coreW) -and -not (Get-ChildItem -Force $coreW | Where-Object { -not $_.PSIsContainer })) {
    if (-not $DryRun) { Remove-Item -Recurse -Force $coreW }
    Log "  - cleaned $coreW"
}

# ---------------------------------------------------------------------------
Log '=== Phase 5: rewrite router + main imports ===' 'Yellow'

$router = Join-Path $lib 'routing\app_router.dart'
if (Test-Path $router) {
    $t = [System.IO.File]::ReadAllText($router)
    $t = $t -replace 'features/([^/]+)/presentation/pages/(\w+)_page\.dart', 'screens/`$2_screen.dart'
    if (-not $DryRun) { [System.IO.File]::WriteAllText($router, $t, [System.Text.UTF8Encoding]::new($false)) }
    Log "  ~ updated $router"
}

# ---------------------------------------------------------------------------
Log '=== Phase 6: widget_test imports ===' 'Yellow'
$testFile = Join-Path $root 'test\widget_test.dart'
if (Test-Path $testFile) {
    $t = [System.IO.File]::ReadAllText($testFile)
    $t = $t -replace "import 'package:sheba_bondhu/core/localization/locale_provider\.dart';",
               "import 'package:sheba_bondhu/core/localization/locale_provider.dart';"
    $t = $t -replace "import 'package:sheba_bondhu/core/storage/app_preferences\.dart';",
               "import 'package:sheba_bondhu/core/storage/app_preferences.dart';"
    if (-not $DryRun) { [System.IO.File]::WriteAllText($testFile, $t, [System.Text.UTF8Encoding]::new($false)) }
    Log "  ~ updated $testFile"
}

Log '=== Migration complete ===' 'Green'
if ($DryRun) { Log '(dry-run — no files actually moved)' 'Magenta' }