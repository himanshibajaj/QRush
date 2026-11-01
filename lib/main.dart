import 'package:flutter/material.dart';
import 'main_shell.dart';
import 'theme.dart';

void main() => runApp(const QRushApp());

class QRushApp extends StatelessWidget {
  const QRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QRush',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      builder: (context, child) =>
          Container(color: AppColors.bg, child: child),
      home: const MainShell(),
    );
  }
}