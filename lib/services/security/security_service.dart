import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';

/// App-wide security lock using 4-digit PIN to protect personal finances & documents.
class SecurityService {
  static const _keyPin = 'app_security_pin';
  static const _keyPinEnabled = 'app_security_pin_enabled';

  static Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPinEnabled) ?? false;
  }

  static Future<bool> verifyPin(String inputPin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_keyPin);
    return savedPin == inputPin;
  }

  static Future<void> setPin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPin, newPin);
    await prefs.setBool(_keyPinEnabled, true);
  }

  static Future<void> disablePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPin);
    await prefs.setBool(_keyPinEnabled, false);
  }

  /// Show PIN setup or toggle dialog
  static Future<void> showPinDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool enabled = prefs.getBool(_keyPinEnabled) ?? false;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final pinController = TextEditingController();
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, color: AppColors.brandGreen),
                const SizedBox(width: 8),
                const Text('অ্যাপ লক ও নিরাপত্তা', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.brandGreen,
                  title: const Text('৪-ডিজিট পিন লক', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('দেনা-পাওনা ও ব্যক্তিগত নথি সুরক্ষিত রাখুন'),
                  value: enabled,
                  onChanged: (val) async {
                    if (!val) {
                      await disablePin();
                      setState(() => enabled = false);
                    } else {
                      setState(() => enabled = true);
                    }
                  },
                ),
                if (enabled) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'নতুন ৪ সংখ্যার পিন লিখুন',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.key_rounded, color: AppColors.brandGreen),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('বাতিল', style: TextStyle(color: AppColors.inkMuted)),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  if (enabled) {
                    final pin = pinController.text.trim();
                    if (pin.length == 4) {
                      await setPin(pin);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('পিন লক সফলভাবে চালু করা হয়েছে!'),
                            backgroundColor: AppColors.brandGreen,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('অনুগ্রহ করে ৪ সংখ্যার পিন দিন'),
                          backgroundColor: AppColors.critical,
                        ),
                      );
                    }
                  } else {
                    await disablePin();
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                child: const Text('সংরক্ষণ করুন'),
              ),
            ],
          );
        },
      ),
    );
  }
}
