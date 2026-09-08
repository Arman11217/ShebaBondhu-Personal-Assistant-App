/**
 * ShebaBondhu (সেবা বন্ধু) - Landing Page Interactive Scripts
 * Handles Live Web OTP Subscription, SMS/USSD clipboard copy, and FAQ accordions.
 */

document.addEventListener('DOMContentLoaded', () => {
  // Configuration
  const CONFIG = {
    appName: 'ShebaBondhu',
    smsKeyword: '11217',
    ussdKeyword: '10757',
    shortCode: '21213',
    baseUrl: 'https://www.bdappsdigitalapps.com/NADB26105_FinalProject/',
    apkDownloadUrl: 'https://www.bdappsdigitalapps.com/NADB26105_FinalProject/sheba_bondhu/ShebaBondhu.apk'
  };

  // -------------------------------------------------------------
  // 1. Copy Code Helper
  // -------------------------------------------------------------
  window.copyCode = function (text, btnElement) {
    if (!navigator.clipboard) {
      // Fallback
      const textarea = document.createElement('textarea');
      textarea.value = text;
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand('copy');
      document.body.removeChild(textarea);
      showCopiedFeedback(btnElement);
      return;
    }

    navigator.clipboard.writeText(text).then(() => {
      showCopiedFeedback(btnElement);
    }).catch(err => {
      console.error('Clipboard copy failed:', err);
    });
  };

  function showCopiedFeedback(btn) {
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fas fa-check"></i> কপি হয়েছে!';
    btn.style.borderColor = '#059669';
    btn.style.color = '#059669';
    setTimeout(() => {
      btn.innerHTML = originalText;
      btn.style.borderColor = '';
      btn.style.color = '';
    }, 2000);
  }

  // -------------------------------------------------------------
  // 2. FAQ Accordion
  // -------------------------------------------------------------
  const faqQuestions = document.querySelectorAll('.faq-question');
  faqQuestions.forEach(q => {
    q.addEventListener('click', () => {
      const parent = q.parentElement;
      const isActive = parent.classList.contains('active');

      // Close all
      document.querySelectorAll('.faq-item').forEach(item => {
        item.classList.remove('active');
      });

      // Toggle current
      if (!isActive) {
        parent.classList.add('active');
      }
    });
  });

  // -------------------------------------------------------------
  // 3. Web OTP Subscription Flow
  // -------------------------------------------------------------
  const phoneForm = document.getElementById('phone-form');
  const otpForm = document.getElementById('otp-form');
  const phoneInput = document.getElementById('user-phone');
  const otpInput = document.getElementById('user-otp');
  const sendOtpBtn = document.getElementById('btn-send-otp');
  const verifyOtpBtn = document.getElementById('btn-verify-otp');
  const formAlert = document.getElementById('form-alert');
  const timerDisplay = document.getElementById('timer-countdown');

  let currentPhone = '';
  let currentReferenceNo = '';
  let countdownTimer = null;
  let remainingSeconds = 240;

  function showAlert(msg, isSuccess = false) {
    formAlert.className = 'form-alert ' + (isSuccess ? 'success' : 'error');
    formAlert.innerHTML = msg;
    formAlert.style.display = 'block';
  }

  function hideAlert() {
    formAlert.style.display = 'none';
  }

  function isRobiAirtel(phone) {
    return /^01(?:6|8)\d{8}$/.test(phone.trim());
  }

  function startTimer() {
    remainingSeconds = 240;
    clearInterval(countdownTimer);
    updateTimerText();

    countdownTimer = setInterval(() => {
      remainingSeconds--;
      updateTimerText();
      if (remainingSeconds <= 0) {
        clearInterval(countdownTimer);
        showAlert('OTP-এর মেয়াদ শেষ হয়েছে। পুনরায় চেষ্টা করুন।');
        verifyOtpBtn.disabled = true;
      }
    }, 1000);
  }

  function updateTimerText() {
    if (!timerDisplay) return;
    const mins = Math.floor(remainingSeconds / 60);
    const secs = remainingSeconds % 60;
    timerDisplay.innerText = `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  // Send OTP
  if (phoneForm) {
    phoneForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      hideAlert();

      const phone = phoneInput.value.trim();
      if (!phone) {
        showAlert('অনুগ্রহ করে মোবাইল নম্বর দিন।');
        return;
      }
      if (!isRobiAirtel(phone)) {
        showAlert('সঠিক Robi বা Cirkle নম্বর দিন (যেমন: 018... অথবা 016...)');
        return;
      }

      currentPhone = phone;
      sendOtpBtn.disabled = true;
      sendOtpBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> ওটিপি পাঠানো হচ্ছে...';

      try {
        // Send request to send_otp.php
        const endpoint = CONFIG.baseUrl + 'send_otp.php';
        const formData = new FormData();
        formData.append('user_mobile', currentPhone);

        const response = await fetch(endpoint, {
          method: 'POST',
          body: formData
        });

        const data = await response.json();

        if (data.success && data.referenceNo) {
          currentReferenceNo = data.referenceNo;
          phoneForm.style.display = 'none';
          otpForm.style.display = 'block';
          showAlert(`<strong>${currentPhone}</strong> নম্বরে ওটিপি (OTP) পাঠানো হয়েছে। কোডটি দিন:`, true);
          startTimer();
        } else if (data.statusCode === 'E1351' || (data.message && data.message.toLowerCase().includes('already registered'))) {
          showAlert(`আপনি ইতিমধ্যে সেবা বন্ধু-তে সাবস্ক্রাইব করেছেন! সরাসরি <a href="${CONFIG.apkDownloadUrl}" style="text-decoration:underline; font-weight:bold;">ShebaBondhu.apk</a> ডাউনলোড করুন।`, true);
        } else {
          showAlert(data.message || data.statusDetail || 'ওটিপি পাঠানো যায়নি। দয়া করে কিছুক্ষণ পর আবার চেষ্টা করুন অথবা SMS/USSD ব্যবহার করুন।');
        }
      } catch (err) {
        console.error('Send OTP error:', err);
        showAlert('গেটওয়ে সার্ভারে সাময়িক সমস্যা হচ্ছে। আপনি চাইলে সরাসরি এসএমএস <strong>START 11217</strong> লিখে <strong>21213</strong> এ পাঠিয়ে সাবস্ক্রাইব করতে পারেন।');
      } finally {
        sendOtpBtn.disabled = false;
        sendOtpBtn.innerHTML = '<i class="fas fa-paper-plane"></i> ওটিপি (OTP) পাঠান';
      }
    });
  }

  // Verify OTP
  if (otpForm) {
    otpForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      hideAlert();

      const otp = otpInput.value.trim();
      if (!otp || otp.length < 4) {
        showAlert('সঠিক ওটিপি (OTP) কোডটি দিন।');
        return;
      }

      verifyOtpBtn.disabled = true;
      verifyOtpBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> যাচাই হচ্ছে...';

      try {
        const endpoint = CONFIG.baseUrl + 'verify_otp.php';
        const formData = new FormData();
        formData.append('Otp', otp);
        formData.append('otp', otp);
        formData.append('referenceNo', currentReferenceNo);
        formData.append('reference_no', currentReferenceNo);
        formData.append('user_mobile', currentPhone);

        const response = await fetch(endpoint, {
          method: 'POST',
          body: formData
        });

        const data = await response.json();
        const statusCode = (data.statusCode || data.StatusCode || data.status_code || '').toUpperCase();
        const isSuccess = data.success === true || statusCode === 'S1000' || (data.status && data.status.toLowerCase() === 'success');

        if (isSuccess) {
          clearInterval(countdownTimer);
          showAlert('🎉 অভিনন্দন! সেবা বন্ধু সাবস্ক্রিপশন সফলভাবে সক্রিয় হয়েছে। অ্যাপ ডাউনলোড শুরু হচ্ছে...', true);
          otpForm.style.display = 'none';

          // Trigger download automatically
          setTimeout(() => {
            window.location.href = CONFIG.apkDownloadUrl;
          }, 1200);
        } else {
          showAlert(data.message || data.statusDetail || 'ভুল ওটিপি কোড দিয়েছেন। আবার চেষ্টা করুন।');
        }
      } catch (err) {
        console.error('Verify OTP error:', err);
        showAlert('যাচাইকরণে নেটওয়ার্ক সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।');
      } finally {
        verifyOtpBtn.disabled = false;
        verifyOtpBtn.innerHTML = '<i class="fas fa-check-circle"></i> সাবস্ক্রিপশন নিশ্চিত করুন';
      }
    });
  }

  // Change phone number button
  const btnChangePhone = document.getElementById('btn-change-phone');
  if (btnChangePhone) {
    btnChangePhone.addEventListener('click', (e) => {
      e.preventDefault();
      clearInterval(countdownTimer);
      otpForm.style.display = 'none';
      phoneForm.style.display = 'block';
      hideAlert();
    });
  }

  // Mobile navigation menu toggle
  const mobileToggle = document.getElementById('mobile-toggle');
  const navLinks = document.querySelector('.nav-links');
  if (mobileToggle && navLinks) {
    const toggleIcon = mobileToggle.querySelector('i');

    function toggleNavMenu(open) {
      const shouldOpen = open !== undefined ? open : !navLinks.classList.contains('active');
      if (shouldOpen) {
        navLinks.classList.add('active');
        if (toggleIcon) {
          toggleIcon.classList.remove('fa-bars');
          toggleIcon.classList.add('fa-xmark');
        }
      } else {
        navLinks.classList.remove('active');
        if (toggleIcon) {
          toggleIcon.classList.remove('fa-xmark');
          toggleIcon.classList.add('fa-bars');
        }
      }
    }

    mobileToggle.addEventListener('click', (e) => {
      e.stopPropagation();
      toggleNavMenu();
    });

    // Close when clicking any nav link
    navLinks.querySelectorAll('a').forEach((link) => {
      link.addEventListener('click', () => {
        toggleNavMenu(false);
      });
    });

    // Close on click outside
    document.addEventListener('click', (e) => {
      if (!navLinks.contains(e.target) && !mobileToggle.contains(e.target)) {
        toggleNavMenu(false);
      }
    });

    // Close on Escape key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        toggleNavMenu(false);
      }
    });
  }
});
