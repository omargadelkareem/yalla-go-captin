import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/yalla_go_captain_logo.dart';
import '../../../home/presentation/pages/captain_home_page.dart';
import 'captain_documents_page.dart';
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
  bool obscurePassword = true;
  String? error;

  bool get validPhone => RegExp(r'^01[0125][0-9]{8}$').hasMatch(phoneController.text.trim());
  bool get validLogin => validPhone && passwordController.text.length >= 6;
  String get phoneKey => '20${phoneController.text.trim().substring(1)}';
  String get authEmail => '$phoneKey@captain.yallago.app';

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!validLogin || loading) return;
    setState(() { loading = true; error = null; });
    try {
      final captainSnapshot = await FirebaseDatabase.instance.ref('captains/$phoneKey').get();
      if (!captainSnapshot.exists) {
        if (mounted) setState(() => error = 'لا يوجد حساب كابتن بهذا الرقم');
        return;
      }
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: authEmail,
        password: passwordController.text,
      );
      final fresh = await FirebaseDatabase.instance.ref('captains/$phoneKey').get();
      if (!fresh.exists || fresh.value is! Map) throw Exception('captain-data-missing');
      CaptainSession.hydrate(phoneKey, Map<String, dynamic>.from(fresh.value as Map));
      await CaptainSession.persistLogin(phoneKey);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => CaptainSession.documentsComplete
              ? const CaptainHomePage()
              : CaptainDocumentsPage(phoneKey: phoneKey),
        ),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.code) {
          case 'wrong-password':
          case 'invalid-credential':
          case 'user-not-found':
            error = 'رقم الموبايل أو كلمة المرور غير صحيحة';
            break;
          case 'too-many-requests':
            error = 'محاولات كثيرة، حاول مرة أخرى بعد قليل';
            break;
          case 'network-request-failed':
            error = 'تحقق من اتصال الإنترنت وحاول مرة أخرى';
            break;
          default:
            error = 'تعذر تسجيل الدخول';
        }
      });
    } catch (_) {
      if (mounted) setState(() => error = 'حدث خطأ أثناء تسجيل الدخول');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _goToRegister() {
    FocusScope.of(context).unfocus();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CaptainRegisterPage()));
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 28),
                    const Center(child: YallaGoCaptainLogo()),
                    const SizedBox(height: 38),
                    const Text('أهلاً بيك يا كابتن', textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                      style: TextStyle(color: AppColors.textDark, fontSize: 29, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    const Text('سجل دخولك وابدأ استقبال الرحلات', textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                    const SizedBox(height: 28),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() => error = null),
                        decoration: InputDecoration(
                          counterText: '', hintText: '01XXXXXXXXX', labelText: 'رقم الموبايل',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Center(widthFactor: 1, child: Text('+20', style: TextStyle(fontWeight: FontWeight.w800))),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                        onChanged: (_) => setState(() => error = null),
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => obscurePassword = !obscurePassword),
                            icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.danger.withOpacity(.08), borderRadius: BorderRadius.circular(14)),
                        child: Text(error!, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                          style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        onPressed: validLogin && !loading ? _login : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.turquoise,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: loading
                            ? const SizedBox(width: 23, height: 23, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                            : const Text('تسجيل الدخول', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('أو')), Expanded(child: Divider())]),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: loading ? null : _goToRegister,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          side: const BorderSide(color: AppColors.navy),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: const Text('إنشاء حساب كابتن جديد', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 30),
                    const Text('Yalla Go Captain', textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
