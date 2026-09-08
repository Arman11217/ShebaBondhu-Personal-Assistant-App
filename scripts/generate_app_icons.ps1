Add-Type -AssemblyName System.Drawing

$sourcePath = "C:\Users\PC\.gemini\antigravity-ide\brain\4d29c26d-2c3a-4a38-bb08-f17fbdca1168\shebabondhu_app_icon_1788386056802.jpg"

if (-not (Test-Path $sourcePath)) {
    Write-Error "Source image not found: $sourcePath"
    exit 1
}

$srcBmp = [System.Drawing.Image]::FromFile($sourcePath)

function Resize-And-Save($destPath, $width, $height) {
    $parentDir = Split-Path -Parent $destPath
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
    }
    
    $destBmp = New-Object System.Drawing.Bitmap($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($destBmp)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    $graphics.DrawImage($srcBmp, 0, 0, $width, $height)
    $destBmp.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)

    $graphics.Dispose()
    $destBmp.Dispose()
    Write-Host "Generated: $destPath (${width}x${height})"
}

# Flutter App Asset
Resize-And-Save "assets\app_icon.png" 512 512

# Landing Page Assets
Resize-And-Save "landing_page\sheba_bondhu\assets\app_icon.png" 512 512
Resize-And-Save "landing_page\sheba_bondhu\favicon.png" 64 64

# Android mipmap launcher icons
Resize-And-Save "android\app\src\main\res\mipmap-mdpi\ic_launcher.png" 48 48
Resize-And-Save "android\app\src\main\res\mipmap-hdpi\ic_launcher.png" 72 72
Resize-And-Save "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png" 96 96
Resize-And-Save "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png" 144 144
Resize-And-Save "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png" 192 192

# Web Icons
Resize-And-Save "web\favicon.png" 64 64
Resize-And-Save "web\icons\Icon-192.png" 192 192
Resize-And-Save "web\icons\Icon-512.png" 512 512
Resize-And-Save "web\icons\Icon-maskable-192.png" 192 192
Resize-And-Save "web\icons\Icon-maskable-512.png" 512 512

$srcBmp.Dispose()
Write-Host "All App Icons Generated Successfully!"
