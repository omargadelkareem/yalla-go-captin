import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';

class CaptainHomePage extends StatefulWidget {
  const CaptainHomePage({super.key});
  @override
  State<CaptainHomePage> createState() => _CaptainHomePageState();
}

class _CaptainHomePageState extends State<CaptainHomePage> {
  bool online = false;

  bool get approved => CaptainSession.status == 'approved';
  bool get activated => approved && CaptainSession.walletBalance >= 100;

  Future<void> _toggle(bool value) async {
    if (!activated) return;
    setState(() => online = value);
    await FirebaseDatabase.instance.ref('captains/${CaptainSession.phoneKey}').update({
      'isOnline': value,
      'lastOnlineAt': ServerValue.timestamp,
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                CircleAvatar(radius: 23, backgroundColor: AppColors.navy, child: Text((CaptainSession.name ?? 'ك')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('أهلاً، ${CaptainSession.name ?? 'كابتن'}', textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  Text(online ? 'أنت متاح لاستقبال الرحلات' : 'أنت غير متصل', textDirection: TextDirection.rtl, style: TextStyle(color: online ? AppColors.success : AppColors.textMuted, fontSize: 11)),
                ])),
                Switch(value: online, activeColor: AppColors.turquoise, onChanged: activated ? _toggle : null),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE4EEF2),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Stack(
                children: [
                  const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.map_rounded, size: 72, color: Color(0xFFB7CAD3)),
                    SizedBox(height: 10),
                    Text('خريطة الرحلات', textDirection: TextDirection.rtl, style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w800)),
                  ])),
                  Positioned(top: 14, left: 14, right: 14, child: _StatusBanner(approved: approved, activated: activated)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 20)]),
              child: Column(
                children: [
                  Row(textDirection: TextDirection.rtl, children: [
                    const Expanded(child: Text('محفظتك', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                    Text('${CaptainSession.walletBalance.toStringAsFixed(0)} ج', style: const TextStyle(color: AppColors.navy, fontSize: 23, fontWeight: FontWeight.w900)),
                  ]),
                  const SizedBox(height: 8),
                  const Row(textDirection: TextDirection.rtl, children: [
                    Icon(Icons.info_outline_rounded, size: 15, color: AppColors.textMuted),
                    SizedBox(width: 6),
                    Expanded(child: Text('بعد الموافقة: رسوم التفعيل 100 ج + أول شحن للمحفظة بحد أدنى 100 ج.', textDirection: TextDirection.rtl, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.approved, required this.activated});
  final bool approved; final bool activated;
  @override
  Widget build(BuildContext context) {
    final title = !approved ? 'حسابك قيد المراجعة' : !activated ? 'الحساب مقبول — أكمل التفعيل والشحن' : 'جاهز للشغل';
    final icon = !approved ? Icons.hourglass_top_rounded : !activated ? Icons.account_balance_wallet_outlined : Icons.verified_rounded;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(18)),
      child: Row(textDirection: TextDirection.rtl, children: [
        Icon(icon, color: AppColors.turquoise),
        const SizedBox(width: 9),
        Expanded(child: Text(title, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12))),
      ]),
    );
  }
}
