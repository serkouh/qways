import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/pages/chatting/chat.dart';
import 'package:qways/pages/home/home.dart';
import 'package:qways/pages/profile/profile.dart';
import 'package:qways/pages/scan/scan.dart';
import 'package:qways/pages/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';

import '../../theme/theme.dart';
import '../notification/notification.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key, this.index});

  final int? index;

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int? selectedIndex;

  DateTime? backPressTime;

  final pages = [
    const QuizDashboard(),
    const NotificationScreen(),
    const RoomsListScreen(),
    const ProfileScreen(),
    const ScanScreen(),
  ];

  @override
  void initState() {
    setState(() {
      selectedIndex = widget.index ?? 0;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    return WillPopScope(
      onWillPop: () async {
        bool backStatus = onWillPop();
        if (backStatus) {
          exit(0);
        } else {
          return false;
        }
      },
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          extendBody: true,
          backgroundColor: whiteColor,
          body: pages.elementAt(selectedIndex!),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Visibility(
            visible: !isKeyboardIsOpen,
            child: FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () {
                setState(() {
                  selectedIndex = 4;
                });
              },
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          bottomNavigationBar: bottomBar(),
        ),
      ),
    );
  }

  bottomBar() {
    return AnimatedBottomNavigationBar(
      gapLocation: GapLocation.center,
      shadow: BoxShadow(
        color: blackColor.withOpacity(0.2),
        blurRadius: 5,
      ),
      notchSmoothness: NotchSmoothness.sharpEdge,
      activeColor: primaryColor,
      inactiveColor: greyB4Color,
      icons: const [
        LineIcons.home,
        LineIcons.bell,
        LineIcons.wallet,
        LineIcons.user,
      ],
      iconSize: 25,
      backgroundColor: whiteColor,
      activeIndex: selectedIndex!,
      onTap: (index) {
        setState(
          () {
            selectedIndex = index;
          },
        );
      },
    );
  }

  onWillPop() {
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
