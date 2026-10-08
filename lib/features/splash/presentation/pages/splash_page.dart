import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/yalla_go_captain_logo.dart';
import '../../../auth/presentation/pages/phone_login_page.dart';
import '../../../auth/presentation/pages/captain_documents_page.dart';
import '../../../home/presentation/pages/captain_home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    final key = CaptainSession.savedPhoneKey;
    if (key != null && key.isNotEmpty) {
      try {
        final snap = await FirebaseDatabase.instance.ref('captains/$key').get();
        if (snap.exists && snap.value is Map) {
          CaptainSession.hydrate(
            key,
            Map<String, dynamic>.from(snap.value as Map),
          );
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CaptainSession.documentsComplete
                  ? const CaptainHomePage()
                  : CaptainDocumentsPage(phoneKey: key),
            ),
          );
          return;
        }
      } catch (_) {
        // Fall back to login when the stored session cannot be refreshed.
      }
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PhoneLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.navy, AppColors.navyDeep],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                YallaGoCaptainLogo(size: 88, showName: false),
                SizedBox(height: 22),
                Text(
                  'Yalla Go',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'CAPTAIN',
                  style: TextStyle(
                    color: AppColors.turquoise,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'وسع دايرة شغلك',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: Color(0xFFD9E6ED), fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      );
}
