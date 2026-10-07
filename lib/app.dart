import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/pages/splash_page.dart';

class YallaGoCaptainApp extends StatelessWidget {
  const YallaGoCaptainApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Yalla Go Captain',
    theme: AppTheme.light,
    home: const SplashPage(),
  );
}
