import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/home/presentation/screens/home_screen.dart';

class TiltMeterApp extends StatelessWidget {
  const TiltMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tilt Meter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
