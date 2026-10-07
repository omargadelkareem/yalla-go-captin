import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/yalla_go_captain_logo.dart';
import '../../../wallet/presentation/pages/wallet_top_up_page.dart';

class CaptainHomePage extends StatefulWidget {
  const CaptainHomePage({super.key});

  @override
  State<CaptainHomePage> createState() => _CaptainHomePageState();
}

class _CaptainHomePageState extends State<CaptainHomePage> {
  bool online = false;

  bool get approved => CaptainSession.status == 'approved';
  bool get activated =>
      approved &&
      CaptainSession.activationPaid &&
      CaptainSession.initialTopUpCompleted;

  Future<void> _toggleOnline() async {
    if (!activated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أكمل التفعيل وشحن المحفظة أولاً')),
      );
      return;
    }
    final value = !online;
    setState(() => online = value);
    try {
      await FirebaseDatabase.instance
          .ref('captains/${CaptainSession.phoneKey}')
          .update({
        'isOnline': value,
        'lastOnlineAt': ServerValue.timestamp,
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => online = !value);
    }
  }

  void _openWallet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WalletTopUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFE5EEF2),
                  child: CustomPaint(painter: _MapPainter()),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Color(0x12000000), blurRadius: 18),
                    ],
                  ),
                  child: Row(
                    children: [
                      _RoundButton(icon: Icons.menu_rounded, onTap: () {}),
                      const Expanded(
                        child: Center(
                          child: YallaGoCaptainLogo(size: 42, showName: false),
                        ),
                      ),
                      _RoundButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 92,
                left: 18,
                right: 18,
                child: GestureDetector(
                  onTap: _toggleOnline,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x16000000),
                          blurRadius: 22,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Container(
                          width: 48,
                          height: 28,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: online
                                ? AppColors.turquoise
                                : const Color(0xFFDDE5E9),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 180),
                            alignment: online
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                online ? 'أنت متصل الآن' : 'أنت غير متصل',
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                online
                                    ? 'جاهز لاستقبال طلبات الرحلات'
                                    : activated
                                        ? 'اضغط للاتصال واستقبال الرحلات'
                                        : 'أكمل تفعيل الحساب والمحفظة أولاً',
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          online
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: online
                              ? AppColors.success
                              : AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: 215,
                left: 0,
                right: 0,
                child: Center(
                  child: _LocationMarker(),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 28,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9E1E5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'محفظتك',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  activated
                                      ? 'رصيد العمولة المتاح'
                                      : 'اشحن المحفظة علشان تبدأ تستقبل رحلات',
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${CaptainSession.walletBalance.toStringAsFixed(0)} ج',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _openWallet,
                          icon: const Icon(Icons.add_card_rounded),
                          label: const Text('شحن المحفظة لاستقبال الرحلات'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'حوّل على 01115057318 ثم ارفع الإيصال للمراجعة',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: 43,
            height: 43,
            child: Icon(icon, color: AppColors.navy),
          ),
        ),
      );
}

class _LocationMarker extends StatelessWidget {
  const _LocationMarker();

  @override
  Widget build(BuildContext context) => Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: Color(0x3308B8C5),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.turquoise,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 5),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 10),
            ],
          ),
        ),
      );
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    final smallRoad = Paint()
      ..color = const Color(0xFFF7FAFB)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final river = Paint()
      ..color = const Color(0xFFBEEAF0)
      ..strokeWidth = 48
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(size.width * .76, -20)
      ..cubicTo(
        size.width * .64,
        size.height * .22,
        size.width * .88,
        size.height * .46,
        size.width * .70,
        size.height * .74,
      );
    canvas.drawPath(riverPath, river);

    for (final y in [.24, .40, .56, .69]) {
      canvas.drawLine(
        Offset(-20, size.height * y),
        Offset(size.width + 20, size.height * (y - .09)),
        road,
      );
    }
    for (final x in [.18, .43, .58]) {
      canvas.drawLine(
        Offset(size.width * x, 70),
        Offset(size.width * (x + .13), size.height * .78),
        smallRoad,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
