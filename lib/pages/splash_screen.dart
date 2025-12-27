import 'dart:async';

import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushNamed(context, '/bottombar');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/App Logo Inspiraton.png",
                height: size.height * 0.095,
                width: size.height * 0.095,
              ),
              height5Space,
              const Text(
                "City rider",
                style: semibold35Primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
