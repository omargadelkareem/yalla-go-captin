import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../wallet/presentation/pages/wallet_top_up_page.dart';

class CaptainHomePage extends StatefulWidget {
  const CaptainHomePage({super.key});

  @override
  State<CaptainHomePage> createState() => _CaptainHomePageState();
}

class _CaptainHomePageState extends State<CaptainHomePage> {
  bool online = false;

  bool get approved => CaptainSession.status == 'approved';
  bool get activated => approved &&
      CaptainSession.activationPaid &&
      CaptainSession.initialTopUpCompleted;

  Future<void> _toggleOnline() async {
    if (!activated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أكمل تفعيل الحساب وشحن المحفظة أولاً')),
      );
      return;
    }
    final next = !online;
    setState(() => online = next);
    try {
      await FirebaseDatabase.instance
          .ref('captains/${CaptainSession.phoneKey}')
          .update({
        'isOnline': next,
        'lastOnlineAt': ServerValue.timestamp,
      });
    } catch (_) {
      if (mounted) setState(() => online = !next);
    }
  }

  void _openWallet() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WalletTopUpPage()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F4),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _MapBackground()),
            Positioned(
              top: 18,
              left: 18,
              right: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassButton(icon: Icons.menu_rounded, onTap: () {}),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.94),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12062B46),
                          blurRadius: 20,
                          offset: Offset(0, 7),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        _MiniBrandMark(),
                        SizedBox(width: 8),
                        Text(
                          'Yalla Go',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _GlassButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Positioned(
              top: 94,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: _toggleOnline,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: online ? AppColors.navy : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1B062B46),
                        blurRadius: 28,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: online
                              ? AppColors.turquoise
                              : AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          online
                              ? Icons.power_settings_new_rounded
                              : Icons.power_settings_new_rounded,
                          color: online ? Colors.white : AppColors.navy,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              online ? 'متصل وجاهز' : 'أنت غير متصل',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: online
                                    ? Colors.white
                                    : AppColors.textDark,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              online
                                  ? 'هنعرض لك الرحلات القريبة فور وصولها'
                                  : activated
                                      ? 'اضغط هنا وابدأ استقبال الرحلات'
                                      : 'أكمل تفعيل الحساب والمحفظة للبدء',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: online
                                    ? Colors.white.withOpacity(.68)
                                    : AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: online
                              ? const Color(0xFF56E29A)
                              : const Color(0xFFBCC8CE),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 210,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x10000000), blurRadius: 16),
                  ],
                ),
                child: const Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(
                      Icons.my_location_rounded,
                      size: 15,
                      color: AppColors.turquoiseDark,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'سوهاج',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned.fill(
              top: 180,
              bottom: 250,
              child: Center(child: _CaptainMapMarker()),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _BottomPanel(
                activated: activated,
                approved: approved,
                online: online,
                onWallet: _openWallet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.activated,
    required this.approved,
    required this.online,
    required this.onWallet,
  });

  final bool activated;
  final bool approved;
  final bool online;
  final VoidCallback onWallet;

  @override
  Widget build(BuildContext context) {
    final subtitle = !approved
        ? 'حسابك قيد المراجعة'
        : !activated
            ? 'اشحن المحفظة لتبدأ استقبال الرحلات'
            : online
                ? 'أنت الآن متاح للرحلات القريبة'
                : 'اتصل علشان تبدأ استقبال الرحلات';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24062B46),
            blurRadius: 34,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE5E9),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9FAFB),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.turquoiseDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'رصيد المحفظة',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${CaptainSession.walletBalance.toStringAsFixed(0)} جنيه',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              subtitle,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onWallet,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 21),
                  SizedBox(width: 7),
                  Text(
                    'شحن المحفظة',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'حوّل على 01115057318 وارفع الإيصال للمراجعة',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withOpacity(.94),
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: AppColors.navy, size: 22),
          ),
        ),
      );
}

class _MiniBrandMark extends StatelessWidget {
  const _MiniBrandMark();

  @override
  Widget build(BuildContext context) => Container(
        width: 27,
        height: 27,
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Icon(
          Icons.near_me_rounded,
          color: AppColors.turquoise,
          size: 15,
        ),
      );
}

class _CaptainMapMarker extends StatelessWidget {
  const _CaptainMapMarker();

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 94,
            height: 94,
            decoration: const BoxDecoration(
              color: Color(0x1F08B8C5),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0x3008B8C5),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: AppColors.navy,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33062B46),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.navigation_rounded,
              size: 14,
              color: AppColors.turquoise,
            ),
          ),
        ],
      );
}

class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFFEAF1F4),
        child: CustomPaint(painter: _MapPainter()),
      );
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final nile = Paint()
      ..color = const Color(0xFFBDE9EE)
      ..strokeWidth = 58
      ..strokeCap = StrokeCap.round;
    final nileEdge = Paint()
      ..color = const Color(0xFFD5F3F5)
      ..strokeWidth = 68
      ..strokeCap = StrokeCap.round;
    final mainRoad = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final street = Paint()
      ..color = const Color(0xFFF8FAFB)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final block = Paint()..color = const Color(0xFFDCE6E9);

    final river = Path()
      ..moveTo(size.width * .78, -30)
      ..cubicTo(
        size.width * .60,
        size.height * .23,
        size.width * .88,
        size.height * .45,
        size.width * .68,
        size.height * .78,
      );
    canvas.drawPath(river, nileEdge);
    canvas.drawPath(river, nile);

    for (final data in [
      [.10, .18, .32, .11],
      [.04, .34, .45, .27],
      [.12, .51, .57, .42],
      [.00, .67, .51, .60],
      [.30, .77, .78, .65],
    ]) {
      canvas.drawLine(
        Offset(size.width * data[0], size.height * data[1]),
        Offset(size.width * data[2], size.height * data[3]),
        mainRoad,
      );
    }

    for (final x in [.12, .31, .48, .58]) {
      canvas.drawLine(
        Offset(size.width * x, size.height * .15),
        Offset(size.width * (x + .09), size.height * .73),
        street,
      );
    }

    for (var i = 0; i < 13; i++) {
      final dx = 18.0 + (i % 4) * 72;
      final dy = 180.0 + (i ~/ 4) * 105;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(dx, dy, 38, 24),
          const Radius.circular(6),
        ),
        block,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
