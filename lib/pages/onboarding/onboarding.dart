import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onboarding/onboarding.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  DateTime? backPressTime;

  final List<Widget> pageList = [
    Column(
      children: [
        Expanded(
          child: Image.asset(
            "assets/onboarding/onboarding1.png",
            width: double.maxFinite,
            fit: BoxFit.cover,
          ),
        ),
        heightSpace,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
          child: Column(
            children: [
              Text(
                translation('onboarding.find_destination'),
                textAlign: TextAlign.center,
                style: bold22BlackText,
              ),
              heightSpace,
              const Text(
                "Lorem ipsum dolor sit amet consectetur. Ornllconsectetur ut praesent aliquam volutpat ornare",
                style: semibold14Grey,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ],
    ),
    Column(
      children: [
        Expanded(
          child: Image.asset(
            "assets/onboarding/onboarding2.png",
            width: double.maxFinite,
            fit: BoxFit.cover,
          ),
        ),
        heightSpace,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
          child: Column(
            children: [
              Text(
                translation('onboarding.scan_code'),
                style: bold22BlackText,
                textAlign: TextAlign.center,
              ),
              heightSpace,
              const Text(
                "Lorem ipsum dolor sit amet consectetur. Ornllconsectetur ut praesent aliquam volutpat ornare",
                style: semibold14Grey,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ],
    ),
    Column(
      children: [
        Expanded(
          child: Image.asset(
            "assets/onboarding/onboarding3.png",
            width: double.maxFinite,
            fit: BoxFit.cover,
          ),
        ),
        heightSpace,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
          child: Column(
            children: [
              Text(
                translation('onboarding.start_ride'),
                style: bold22BlackText,
                textAlign: TextAlign.center,
              ),
              heightSpace,
              const Text(
                "Lorem ipsum dolor sit amet consectetur. Ornllconsectetur ut praesent aliquam volutpat ornare",
                style: semibold14Grey,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (onWillPop()) {
          exit(0);
        } else {
          return false;
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          body: Onboarding(
            swipeableBody: pageList,
            startIndex: currentIndex,
            animationInMilliseconds: 500,
            onPageChanges:
                (netDragDistance, pagesLength, index, slideDirection) {
              setState(() {
                currentIndex = index;
              });
            },
            buildHeader: (context, netDragDistance, pagesLength, index,
                setIndex, slideDirection) {
              return const SizedBox(); // Empty header, or add custom header here
            },
            buildFooter: (context, netDragDistance, pagesLength, index,
                setIndex, slideDirection) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  heightSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pagesLength,
                      (dotIndex) => _buildDot(dotIndex),
                    ),
                  ),
                  heightSpace,
                  index == pagesLength - 1
                      ? loginButton()
                      : nextButton(setIndex),
                  index == pagesLength - 1
                      ? const SizedBox()
                      : skipButton(context),
                  heightSpace,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget skipButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/login');
      },
      child: Text(
        getTranslation(context, 'onboarding.skip'),
        style: semibold16Grey,
      ),
    );
  }

  Widget loginButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/login');
      },
      child: Container(
        width: double.maxFinite,
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        padding: const EdgeInsets.all(fixPadding * 1.4),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'onboarding.login'),
          style: bold18White,
        ),
      ),
    );
  }

  Widget nextButton(Function setIndex) {
    return GestureDetector(
      onTap: () {
        setIndex(currentIndex + 1);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        width: double.maxFinite,
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        padding: const EdgeInsets.symmetric(vertical: fixPadding * 1.6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'onboarding.next'),
          style: bold18White.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      height: 10,
      width: 10,
      margin: const EdgeInsets.symmetric(horizontal: fixPadding / 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: currentIndex == index ? primaryColor : greyD9Color,
      ),
    );
  }

  bool onWillPop() {
    DateTime now = DateTime.now();
    if (backPressTime == null ||
        now.difference(backPressTime!) > const Duration(seconds: 2)) {
      backPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          backgroundColor: blackColor,
          content: Text(
            getTranslation(context, 'app_exit.exit_text'),
            style: semibold16White,
          ),
        ),
      );
      return false;
    } else {
      return true;
    }
  }
}
