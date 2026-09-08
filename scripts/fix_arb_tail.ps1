# Fix app_en.arb: remove both stray quickAdd* blocks and reinsert one clean block before the closing }
$file = "lib\core\localization\arb\app_en.arb"
$raw = Get-Content -Raw -Path $file -Encoding UTF8
Write-Host "File length before: $($raw.Length)"

# Find first occurrence of the stray block marker
$marker = '"quickAddTitle":'
$idx = $raw.IndexOf($marker)
if ($idx -lt 0) {
    Write-Host "No stray block found, aborting."
    exit 0
}
Write-Host "First stray quickAddTitle index: $idx"

# Take everything BEFORE the first stray occurrence; that includes the @taskCompletedOnDate placeholder block but NO trailing comma after its closing }
$body = $raw.Substring(0, $idx)

# Trim trailing whitespace from body
$body = $body.TrimEnd()

# The body currently ends with the closing `}` of @taskCompletedOnDate's metadata block, with NO comma.
# Add the comma so the quickAdd keys can continue.
if ($body.EndsWith('}')) {
    $body = $body + ','
}

# Compose the clean quickAdd block (English)
$cleanBlock = @'

  "quickAddTitle": "Quick Add",
  "quickAddParseButton": "Find the right place",
  "quickAddGoButton": "Continue",
  "quickAddExamplesTitle": "Try saying",
  "quickAddHintMoney": "Rahim owes me 500 taka",
  "quickAddHintBill": "Electricity bill 1200 due tomorrow",
  "quickAddHintTask": "Pick up parcel in 3 days",
  "quickAddHintFamily": "Mom's birthday next week",
  "quickAddIntentMoney": "Money manager",
  "quickAddIntentBill": "Bill Bondhu",
  "quickAddIntentDocument": "Kagoj Bondhu",
  "quickAddIntentWarranty": "Warranty Bondhu",
  "quickAddIntentMedicine": "Medicine Bondhu",
  "quickAddIntentSim": "Recharge Bondhu",
  "quickAddIntentFamily": "Family Bondhu",
  "quickAddIntentTask": "Tasks Bondhu",
  "quickAddPreviewDestination": "I will add this to",
  "quickAddPreviewTitle": "Title",
  "quickAddPreviewExtracted": "What I picked up",
  "quickAddSpeechUnavailable": "Speech recognition not available on this device.",
  "quickAddVoiceTooltip": "Voice",
  "quickAddVoiceUnavailableTooltip": "Voice unavailable"
}
'@

$newContent = $body + "`r`n" + $cleanBlock
Set-Content -Path $file -Value $newContent -Encoding UTF8 -NoNewline

$verify = Get-Content -Raw -Path $file -Encoding UTF8
Write-Host "File length after: $($verify.Length)"
Write-Host "Occurrences of quickAddTitle: $([regex]::Matches($verify, '"quickAddTitle":').Count)"
Write-Host "Ends with: $($verify.Substring([Math]::Max(0, $verify.Length - 80)))"
