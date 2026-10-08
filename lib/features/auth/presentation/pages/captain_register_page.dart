import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';
import 'captain_documents_page.dart';

class CaptainRegisterPage extends StatefulWidget {
  const CaptainRegisterPage({super.key, required this.phone, required this.phoneKey, required this.password});
  final String phone;
  final String phoneKey;
  final String password;

  @override
  State<CaptainRegisterPage> createState() => _CaptainRegisterPageState();
}

class _CaptainRegisterPageState extends State<CaptainRegisterPage> {
  final name = TextEditingController();
  final nationalId = TextEditingController();
  final vehicleModel = TextEditingController();
  final plate = TextEditingController();
  String vehicleType = 'motorcycle';
  bool loading = false;

  bool get valid => name.text.trim().length >= 3 && nationalId.text.trim().length == 14 &&
      vehicleModel.text.trim().isNotEmpty && plate.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!valid || loading) return;
    setState(() => loading = true);
    final data = <String, dynamic>{
      'name': name.text.trim(),
      'phone': widget.phone,
      'phoneInternational': '+20${widget.phone.substring(1)}',
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
    try {
      final account = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: '${widget.phoneKey}@captain.yallago.app',
        password: widget.password,
      );
      data['authUid'] = account.user?.uid;
      await FirebaseDatabase.instance.ref('captains/${widget.phoneKey}').set(data);
      CaptainSession.hydrate(widget.phoneKey, data);
      await CaptainSession.persistLogin(widget.phoneKey);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => CaptainDocumentsPage(phoneKey: widget.phoneKey)),
        (_) => false,
      );
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر إنشاء الحساب حالياً')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget field(TextEditingController c, String label, {TextInputType? type, int? max}) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: TextField(
      controller: c,
      keyboardType: type,
      maxLength: max,
      onChanged: (_) => setState(() {}),
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(labelText: label, counterText: ''),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('إنشاء حساب كابتن'), backgroundColor: Colors.transparent),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text('بياناتك الأساسية', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('هنراجع البيانات قبل تفعيل الحساب واستقبال الرحلات.', textDirection: TextDirection.rtl, style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 24),
          field(name, 'الاسم بالكامل'),
          field(nationalId, 'الرقم القومي', type: TextInputType.number, max: 14),
          Row(
            children: [
              Expanded(child: _VehicleChoice(label: 'موتوسيكل', icon: Icons.two_wheeler_rounded, selected: vehicleType == 'motorcycle', onTap: () => setState(() => vehicleType = 'motorcycle'))),
              const SizedBox(width: 10),
              Expanded(child: _VehicleChoice(label: 'عربية', icon: Icons.directions_car_filled_rounded, selected: vehicleType == 'car', onTap: () => setState(() => vehicleType = 'car'))),
            ],
          ),
          const SizedBox(height: 13),
          field(vehicleModel, vehicleType == 'car' ? 'موديل العربية' : 'موديل الموتوسيكل'),
          field(plate, 'رقم اللوحة'),
          const SizedBox(height: 14),
          FilledButton(onPressed: valid && !loading ? _submit : null, child: Text(loading ? 'جاري إنشاء الحساب...' : 'إرسال للمراجعة')),
        ],
      ),
    ),
  );
}

class _VehicleChoice extends StatelessWidget {
  const _VehicleChoice({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label; final IconData icon; final bool selected; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE7FAFB) : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: selected ? AppColors.turquoise : const Color(0xFFE3E9ED), width: 1.4),
      ),
      child: Column(children: [Icon(icon, color: AppColors.navy, size: 34), const SizedBox(height: 7), Text(label, textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.w800))]),
    ),
  );
}
