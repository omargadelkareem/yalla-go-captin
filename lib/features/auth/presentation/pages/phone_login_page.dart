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
  final controller = TextEditingController();
  bool loading = false;
  String? error;
  bool get valid => RegExp(r'^01[0125][0-9]{8}$').hasMatch(controller.text.trim());
  String get key => '20${controller.text.trim().substring(1)}';

  Future<void> _continue() async {
    if (!valid || loading) return;
    setState(() { loading = true; error = null; });
    try {
      final snap = await FirebaseDatabase.instance.ref('captains/$key').get();
      if (!mounted) return;
      if (snap.exists && snap.value is Map) {
        CaptainSession.hydrate(key, Map<String, dynamic>.from(snap.value as Map));
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CaptainHomePage()), (_) => false);
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => CaptainRegisterPage(phone: controller.text.trim(), phoneKey: key)));
      }
    } catch (_) {
      if (mounted) setState(() => error = 'تعذر الاتصال بالسيرفر. تأكد من إعداد Firebase وحاول تاني.');
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
            const SizedBox(height: 40),
            const Text('ادخل ككابتن', textDirection: TextDirection.rtl, textAlign: TextAlign.right,
              style: TextStyle(color: AppColors.textDark, fontSize: 29, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('اكتب رقم موبايلك للدخول أو إنشاء حساب كابتن جديد.', textDirection: TextDirection.rtl, textAlign: TextAlign.right,
              style: TextStyle(color: AppColors.textMuted, height: 1.6)),
            const SizedBox(height: 22),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                onChanged: (_) => setState(() => error = null),
                decoration: const InputDecoration(counterText: '', hintText: '01XXXXXXXXX', prefixIcon: Center(widthFactor: 1, child: Text('+20'))),
              ),
            ),
            if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, textDirection: TextDirection.rtl, style: const TextStyle(color: AppColors.danger))),
            const Spacer(),
            FilledButton(
              onPressed: valid && !loading ? _continue : null,
              child: loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white)) : const Text('متابعة'),
            ),
          ],
        ),
      ),
    ),
  );
}
