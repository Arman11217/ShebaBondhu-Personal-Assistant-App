# সেবা বন্ধু (ShebaBondhu) — ল্যান্ডিং পেজ ডেপ্লয়মেন্ট গাইড (Step 4)

এই ফোল্ডারে bdapps নির্দেশিকা ও নীতিমালা অনুযায়ী তৈরি করা **ShebaBondhu** অ্যাপের সম্পূর্ণ প্রফেশনাল ল্যান্ডিং পেজ প্রস্তুত রয়েছে।

---

## 📁 ফাইল ও ফোল্ডার পরিচিতি
```text
landing_page/
└── sheba_bondhu/
    ├── index.html       (মূল ল্যান্ডিং পেজ)
    ├── style.css        (আধুনিক রেসপন্সিভ ডিজাইন ও কালার স্টাইল)
    ├── script.js        (অনলাইন ওটিপি সাবস্ক্রিপশন, কপি বাটন ও এফএকিউ লজিক)
    ├── favicon.png      (ব্রাউজার ট্যাব আইকন)
    └── assets/
        ├── app_icon.png (অ্যাপের লোগো)
        └── hero_mockup.jpg (প্রিমিয়াম ৩ডি ভিজ্যুয়াল ব্যানার)
```

---

## 🌐 সার্ভার ও ইউআরএল ডিটেইলস (আপনার দেওয়া তথ্য অনুযায়ী)

| প্যারামিটার | মান (Value) |
| :--- | :--- |
| **Shared IP** | `176.9.54.45` |
| **Base Server URL** | `https://www.bdappsdigitalapps.com/NADB26105_FinalProject/` |
| **Landing Page URL** | `https://www.bdappsdigitalapps.com/NADB26105_FinalProject/sheba_bondhu` |
| **App Download APK Link** | `https://www.bdappsdigitalapps.com/NADB26105_FinalProject/sheba_bondhu/ShebaBondhu.apk` |
| **App Name** | `ShebaBondhu` (সেবা বন্ধু) |
| **BDAPPS APP ID** | `APP_139868` |
| **API Key** | `d70bde968bb373c54707c0d279ede783` |
| **SMS Keyword** | `START 11217` to `21213` |
| **USSD Keyword** | `*21213*10757#` |
| **Unsubscribe SMS** | `STOP 11217` to `21213` |
| **Mandatory Charge** | `Daily charge is 2.78 BDT (including VAT, SD & SC). For Robi and Cirkle users only.` |

---

## 🚀 সার্ভারে আপলোড করার ধাপসমূহ:

### ধাপ ১: `sheba_bondhu` ফোল্ডারটি সার্ভারে আপলোড করুন
1. আপনার হোস্টিং cPanel / File Manager অথবা FTP ক্লায়েন্টে লগইন করুন।
2. সার্ভারের `public_html/NADB26105_FinalProject/` ডিরেক্টরিতে যান (যেখানে আপনার php ফাইলগুলো রয়েছে)।
3. সেখানে `sheba_bondhu` নামে ফোল্ডার তৈরি করুন (যদি না থাকে)।
4. এই প্রজেক্টের `landing_page/sheba_bondhu/` ফোল্ডারের সমস্ত ফাইল ও সাবফোল্ডার (`index.html`, `style.css`, `script.js`, `favicon.png`, `assets/`) আপলোড করে দিন।

### ধাপ ২: রিলিজ APK ফাইলটি আপলোড করুন
1. আপনার ফ্লাটার প্রজেক্ট থেকে রিলিজ বিল্ড কমান্ড চালান:
   ```bash
   flutter build apk --release
   ```
2. বিল্ড করা `build/app/outputs/flutter-apk/app-release.apk` ফাইলটির নাম পরিবর্তন করে রাখুন:
   **`ShebaBondhu.apk`**
3. এই `ShebaBondhu.apk` ফাইলটি সরাসরি সার্ভারের `sheba_bondhu/` ফোল্ডারের ভেতরে আপলোড করে দিন।
4. ফলে স্বয়ংক্রিয়ভাবে ডাউনলোড লিঙ্কটি কার্যকর হয়ে যাবে:
   `https://www.bdappsdigitalapps.com/NADB26105_FinalProject/sheba_bondhu/ShebaBondhu.apk`

---

## 🔍 ল্যান্ডিং পেজে যা যা অন্তর্ভুক্ত রয়েছে (bdapps কমপ্লায়েন্স):
1. **অ্যান্ড্রয়েড অ্যাপ ও অপারেটর ঘোষণা:** স্পষ্টভাবে লেখা আছে এটি শুধুমাত্র রবি এবং Cirkle গ্রাহকদের জন্য অ্যান্ড্রয়েড (Android 7.0+) অ্যাপ।
2. **বাধ্যতামূলক চার্জিং ডিসক্লেমার:** 
   *"Daily charge is 2.78 BDT (including VAT, SD & SC). For Robi and Cirkle users only."*
3. **৩টি সাবস্ক্রিপশন পদ্ধতি:**
   * এসএমএস: `START 11217` লিখে `21213` এ পাঠানো (এক ক্লিকে কপি করার সুবিধা সহ)।
   * ইউএসএসডি: `*21213*10757#` ডায়াল করা।
   * **সরাসরি অনলাইন ওটিপি ফর্ম:** ওয়েবসাইট থেকেই নম্বর দিয়ে `send_otp.php` ও `verify_otp.php` এর মাধ্যমে সাবস্ক্রিপশন সম্পন্ন করার লাইভ সিস্টেম।
4. **আনসাবস্ক্রাইব নির্দেশিকা:**
   * `STOP 11217` লিখে `21213` এ পাঠানোর নিয়ম এবং অ্যাপ ড্রয়ার থেকে আনসাবস্ক্রাইব করার পদ্ধতি।
5. **ফিচার বিবরণী ও সাধারণ প্রশ্নোত্তর (FAQ):**
   * দেনা-পাওনা, ইউটিলিটি বিল, ওষুধের রিমাইন্ডার, জরুরি দলিল ভল্ট ইত্যাদি বিস্তারিত আলোচনা।
