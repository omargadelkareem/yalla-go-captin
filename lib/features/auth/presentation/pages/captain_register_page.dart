import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/yalla_go_captain_logo.dart';
import 'captain_documents_page.dart';

class CaptainRegisterPage extends StatefulWidget {
  const CaptainRegisterPage({super.key});

  @override
  State<CaptainRegisterPage> createState() => _CaptainRegisterPageState();
}

class _CaptainRegisterPageState extends State<CaptainRegisterPage> {
  final phone = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final name = TextEditingController();
  final nationalId = TextEditingController();
  final vehicleModel = TextEditingController();
  final plate = TextEditingController();

  String vehicleType = 'motorcycle';
  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  String? error;

  bool get validPhone => RegExp(r'^01[0125][0-9]{8}$').hasMatch(phone.text.trim());
  bool get valid => validPhone &&
      password.text.length >= 6 &&
      password.text == confirmPassword.text &&
      name.text.trim().length >= 3 &&
      nationalId.text.trim().length == 14 &&
      vehicleModel.text.trim().isNotEmpty &&
      plate.text.trim().isNotEmpty;
  String get phoneKey => '20${phone.text.trim().substring(1)}';
  String get authEmail => '$phoneKey@captain.yallago.app';

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (loading) return;
    if (!validPhone) { setState(() => error = 'اكتب رقم موبايل مصري صحيح'); return; }
    if (password.text.length < 6) { setState(() => error = 'كلمة المرور يجب ألا تقل عن 6 أحرف'); return; }
    if (password.text != confirmPassword.text) { setState(() => error = 'كلمتا المرور غير متطابقتين'); return; }
    if (!valid) { setState(() => error = 'أكمل كل البيانات المطلوبة بشكل صحيح'); return; }

    setState(() { loading = true; error = null; });
    UserCredential? created;
    try {
      final existing = await FirebaseDatabase.instance.ref('captains/$phoneKey').get();
      if (existing.exists) {
        if (mounted) setState(() => error = 'يوجد حساب مسجل بهذا الرقم بالفعل، سجل دخولك');
        return;
      }
      created = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: authEmail, password: password.text);
      final uid = created.user?.uid;
      if (uid == null) throw Exception('auth-uid-missing');

      final p = phone.text.trim();
      final data = <String, dynamic>{
        'authUid': uid,
        'name': name.text.trim(),
        'phone': p,
        'phoneInternational': '+20${p.substring(1)}',
        'nationalId': nationalId.text.trim(),
        'vehicleType': vehicleType,
        'vehicleModel': vehicleModel.text.trim(),
        'plateNumber': plate.text.trim(),
        'documentsComplete': false,
        'status': 'pending',
        'activationPaid': false,
        'initialTopUpCompleted': false,
        'walletBalance': 0,
        'isOnline': false,
        'rating': 5.0,
        'tripsCount': 0,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      };
      await FirebaseDatabase.instance.ref('captains/$phoneKey').set(data);
      CaptainSession.hydrate(phoneKey, data);
      await CaptainSession.persistLogin(phoneKey);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => CaptainDocumentsPage(phoneKey: phoneKey)),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.code) {
          case 'email-already-in-use': error = 'يوجد حساب مسجل بهذا الرقم بالفعل'; break;
          case 'weak-password': error = 'كلمة المرور ضعيفة'; break;
          case 'network-request-failed': error = 'تحقق من اتصال الإنترنت وحاول مرة أخرى'; break;
          default: error = 'تعذر إنشاء الحساب';
        }
      });
    } catch (_) {
      try { await created?.user?.delete(); } catch (_) {}
      if (mounted) setState(() => error = 'حدث خطأ أثناء إنشاء الحساب، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  InputDecoration deco(String label, {IconData? icon}) => InputDecoration(
    labelText: label,
    counterText: '',
    prefixIcon: icon == null ? null : Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
  );

  Widget field(TextEditingController c, String label, {TextInputType? type, int? max, IconData? icon}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        controller: c, keyboardType: type, maxLength: max,
        onChanged: (_) => setState(() => error = null),
        decoration: deco(label, icon: icon),
      ),
    ),
  );

  Widget passField(TextEditingController c, String label, bool obscure, VoidCallback toggle) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        controller: c, obscureText: obscure,
        onChanged: (_) => setState(() => error = null),
        decoration: deco(label, icon: Icons.lock_outline_rounded).copyWith(
          suffixIcon: IconButton(
            onPressed: toggle,
            icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          ),
        ),
      ),
    ),
  );

  @override
  void dispose() {
    phone.dispose(); password.dispose(); confirmPassword.dispose(); name.dispose();
    nationalId.dispose(); vehicleModel.dispose(); plate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: const Text('إنشاء حساب كابتن', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900)),
    ),
    body: SafeArea(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 35),
        children: [
          const Center(child: YallaGoCaptainLogo(size: 62)),
          const SizedBox(height: 24),
          const Text('انضم ككابتن', textDirection: TextDirection.rtl, textAlign: TextAlign.right,
            style: TextStyle(color: AppColors.textDark, fontSize: 27, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          const Text('أنشئ حسابك وأكمل بياناتك، وبعدها ارفع المستندات للمراجعة.',
            textDirection: TextDirection.rtl, textAlign: TextAlign.right,
            style: TextStyle(color: AppColors.textMuted, height: 1.6)),
          const SizedBox(height: 24),
          Directionality(
            textDirection: TextDirection.ltr,
            child: TextField(
              controller: phone, keyboardType: TextInputType.phone, maxLength: 11,
              onChanged: (_) => setState(() => error = null),
              decoration: deco('رقم الموبايل').copyWith(
                hintText: '01XXXXXXXXX',
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Center(widthFactor: 1, child: Text('+20', style: TextStyle(fontWeight: FontWeight.w800))),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          passField(password, 'كلمة المرور', obscurePassword, () => setState(() => obscurePassword = !obscurePassword)),
          passField(confirmPassword, 'تأكيد كلمة المرور', obscureConfirm, () => setState(() => obscureConfirm = !obscureConfirm)),
          field(name, 'الاسم بالكامل', icon: Icons.badge_outlined),
          field(nationalId, 'الرقم القومي', type: TextInputType.number, max: 14, icon: Icons.credit_card_rounded),
          const SizedBox(height: 4),
          const Text('نوع المركبة', textDirection: TextDirection.rtl, textAlign: TextAlign.right,
            style: TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _VehicleChoice(label: 'موتوسيكل', icon: Icons.two_wheeler_rounded, selected: vehicleType == 'motorcycle', onTap: () => setState(() => vehicleType = 'motorcycle'))),
            const SizedBox(width: 10),
            Expanded(child: _VehicleChoice(label: 'عربية', icon: Icons.directions_car_filled_rounded, selected: vehicleType == 'car', onTap: () => setState(() => vehicleType = 'car'))),
          ]),
          const SizedBox(height: 16),
          field(vehicleModel, vehicleType == 'car' ? 'موديل العربية' : 'موديل الموتوسيكل', icon: Icons.directions_car_outlined),
          field(plate, 'رقم اللوحة', icon: Icons.pin_outlined),
          if (error != null) ...[
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: AppColors.danger.withOpacity(.08), borderRadius: BorderRadius.circular(14)),
              child: Text(error!, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 14),
          ],
          SizedBox(
            height: 57,
            child: FilledButton(
              onPressed: valid && !loading ? _register : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.turquoise,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: loading
                  ? const SizedBox(width: 23, height: 23, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                  : const Text('متابعة ورفع المستندات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 12),
          const Text('بعد التسجيل هترفع صورتك، البطاقة، الرخصة وصورة المركبة.',
            textDirection: TextDirection.rtl, textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    ),
  );
}

class _VehicleChoice extends StatelessWidget {
  const _VehicleChoice({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE7FAFB) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: selected ? AppColors.turquoise : const Color(0xFFE3E9ED), width: selected ? 1.7 : 1.2),
      ),
      child: Column(children: [
        Icon(icon, color: selected ? AppColors.turquoiseDark : AppColors.navy, size: 34),
        const SizedBox(height: 8),
        Text(label, textDirection: TextDirection.rtl, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800)),
      ]),
    ),
  );
}
