
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
