import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/yalla_go_captain_logo.dart';
import '../../../home/presentation/pages/captain_home_page.dart';
import 'captain_register_page.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool obscure = true;
  String? error;

  bool get valid =>
      RegExp(r'^01[0125][0-9]{8}$').hasMatch(phoneController.text.trim()) &&
      passwordController.text.length >= 6;

  String get phoneKey => '20${phoneController.text.trim().substring(1)}';

  String _hash(String value) => sha256.convert(utf8.encode(value)).toString();

  Future<void> _continue() async {
    if (!valid || loading) return;
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final snap =
          await FirebaseDatabase.instance.ref('captains/$phoneKey').get();
      if (!mounted) return;

      if (snap.exists && snap.value is Map) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        final storedHash = data['passwordHash']?.toString();

        if (storedHash == null || storedHash != _hash(passwordController.text)) {
          setState(() => error = 'رقم الموبايل أو كلمة المرور غير صحيحة');
          return;
        }

        CaptainSession.hydrate(phoneKey, data);
        await CaptainSession.persistLogin(phoneKey);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CaptainHomePage()),
          (_) => false,
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CaptainRegisterPage(
              phone: phoneController.text.trim(),
              phoneKey: phoneKey,
              password: passwordController.text,
            ),
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => error = e.code == 'permission-denied'
          ? 'Firebase رفض قراءة بيانات الكباتن. راجع Realtime Database Rules.'
          : 'خطأ Firebase: ${e.code}');
    } catch (_) {
      if (mounted) setState(() => error = 'تعذر الاتصال بالسيرفر');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const YallaGoCaptainLogo(),
                const SizedBox(height: 34),
                const Text(
                  'دخول الكابتن',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ادخل رقم موبايلك وكلمة المرور. لو الرقم جديد هنكمل إنشاء الحساب.',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: AppColors.textMuted, height: 1.6),
                ),
                const SizedBox(height: 22),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    onChanged: (_) => setState(() => error = null),
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: '01XXXXXXXXX',
                      prefixIcon: Center(widthFactor: 1, child: Text('+20')),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  textDirection: TextDirection.rtl,
                  onChanged: (_) => setState(() => error = null),
                  decoration: InputDecoration(
                    hintText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => obscure = !obscure),
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      error!,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: valid && !loading ? _continue : null,
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text('متابعة'),
                ),
              ],
            ),
          ),
        ),
      );
}
