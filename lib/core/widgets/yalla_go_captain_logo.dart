import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class YallaGoCaptainLogo extends StatelessWidget {
  const YallaGoCaptainLogo({super.key, this.size = 74, this.showName = true});
  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(size * .3),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 22, offset: Offset(0, 10))],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.location_on_rounded, size: size * .62, color: AppColors.white),
            Icon(Icons.near_me_rounded, size: size * .27, color: AppColors.turquoise),
          ],
        ),
      ),
      if (showName) ...[
        const SizedBox(height: 12),
        const Text('Yalla Go', style: TextStyle(color: AppColors.navy, fontSize: 25, fontWeight: FontWeight.w900)),
        const Text('CAPTAIN', style: TextStyle(color: AppColors.turquoiseDark, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 3)),
      ],
    ],
  );
}
