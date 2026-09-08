# Fix app_bn.arb: remove stray quickAdd* block and reinsert a clean block before the closing }
$file = "lib\core\localization\arb\app_bn.arb"
$raw = Get-Content -Raw -Path $file -Encoding UTF8
Write-Host "File length before: $($raw.Length)"

$marker = '"quickAddTitle":'
$idx = $raw.IndexOf($marker)
if ($idx -lt 0) {
    Write-Host "No stray block found, aborting."
    exit 0
}
Write-Host "First stray quickAddTitle index: $idx"

$body = $raw.Substring(0, $idx).TrimEnd()

if ($body.EndsWith('}')) {
    $body = $body + ','
}

$cleanBlock = @'

  "quickAddTitle": "দ্রুত যোগ করুন",
  "quickAddParseButton": "সঠিক জায়গায় পাঠান",
  "quickAddGoButton": "চালিয়ে যান",
  "quickAddExamplesTitle": "এভাবে বলুন...",
  "quickAddHintMoney": "রহিমের কাছ থেকে ৫০০ টাকা পাব",
  "quickAddHintBill": "বিদ্যুৎ বিল ১২০০ টাকা আগামীকাল",
  "quickAddHintTask": "৩ দিনের মধ্যে পার্সেল তুলতে হবে",
  "quickAddHintFamily": "মায়ের জন্মদিন পরের সপ্তাহে",
  "quickAddIntentMoney": "টাকা বন্ধু",
  "quickAddIntentBill": "বিল বন্ধু",
  "quickAddIntentDocument": "কাগজ বন্ধু",
  "quickAddIntentWarranty": "ওয়ারেন্টি বন্ধু",
  "quickAddIntentMedicine": "ওষুধ বন্ধু",
  "quickAddIntentSim": "রিচার্জ বন্ধু",
  "quickAddIntentFamily": "পরিবার বন্ধু",
  "quickAddIntentTask": "কাজ বন্ধু",
  "quickAddPreviewDestination": "আমি এটা যোগ করব",
  "quickAddPreviewTitle": "শিরোনাম",
  "quickAddPreviewExtracted": "আমি যা বুঝেছি",
  "quickAddSpeechUnavailable": "এই ডিভাইসে ভয়েস ইনপুট কাজ করছে না।",
  "quickAddVoiceTooltip": "ভয়েস",
  "quickAddVoiceUnavailableTooltip": "ভয়েস পাওয়া যাচ্ছে না"
}
'@

$newContent = $body + "`r`n" + $cleanBlock
Set-Content -Path $file -Value $newContent -Encoding UTF8 -NoNewline

$verify = Get-Content -Raw -Path $file -Encoding UTF8
Write-Host "File length after: $($verify.Length)"
Write-Host "Occurrences of quickAddTitle: $([regex]::Matches($verify, '"quickAddTitle":').Count)"
Write-Host "Ends with: $($verify.Substring([Math]::Max(0, $verify.Length - 80)))"
