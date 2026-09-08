$ErrorActionPreference = 'Stop'
$path = 'lib\core\localization\arb\app_en.arb'
$lines = Get-Content $path
# Find the stray block: lines starting with 2 spaces and "quickAdd" appear AFTER the closing brace
$closeIdx = -1
for ($i = $lines.Length - 1; $i -ge 0; $i--) {
    if ($lines[$i] -eq '}') { $closeIdx = $i; break }
}
Write-Output "closing brace at line: $closeIdx (of $($lines.Length))"
# Find the first 'quickAdd' line (the stray block start)
$firstQuick = -1
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match '^\s+"quickAdd') { $firstQuick = $i; break }
}
Write-Output "first quickAdd line at: $firstQuick"
# Move that block (from firstQuick to end) to just before the closing brace at closeIdx.
# Clean mojibake + embedded newlines.
$stray = @()
for ($i = $firstQuick; $i -lt $lines.Length; $i++) {
    $ln = $lines[$i] -replace [char]0xFFFD, '...' # replacement char
    $ln = $ln -replace [char]0x00BD, '' # stray fragment
    $ln = $ln -replace 'Try saying\.{3}', 'Try saying...'
    $ln = $ln -replace 'on this device\.\s*"$', 'on this device.",'
    $ln = $ln -replace "`r`n", " "
    $ln = $ln -replace "`n", " "
    $stray += $ln
}
# Drop empty lines
$stray = $stray | Where-Object { $_.Trim().Length -gt 0 }
# Header (last real key before close was taskCompletedOnDate — already a valid entry ending in } so we just inject after it).
# Find the line index where the block should be inserted: right after the last `@taskCompletedOnDate` closing `}`
# But closeIdx already points to the file's closing brace. Insert before it.
$before = $lines[0..($closeIdx - 1)]
$after  = $lines[$closeIdx..($lines.Length - 1)]
# Convert stray lines: each must end with a comma (except last)
$strayFixed = @()
for ($i = 0; $i -lt $stray.Count; $i++) {
    $ln = $stray[$i]
    if ($i -lt $stray.Count - 1) {
        if ($ln -notmatch ',\s*$') { $ln = $ln.TrimEnd() + ',' }
    } else {
        if ($ln -match ',\s*$') { $ln = $ln.TrimEnd(',') }
    }
    $strayFixed += $ln
}
$newLines = $before + $strayFixed + $after
$newLines | Out-File -FilePath $path -Encoding utf8 -NoNewline
Write-Output "rewrote arb: $($newLines.Length) lines, $((Get-Item $path).Length) bytes"