import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qways/theme/theme.dart';
import 'package:qways/localization/localization_const.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? savedEmail;

  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
    startTimer();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedEmail = prefs.getString("user_email");
    });
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }

  // ================= TIMER =================

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void resetTimer() {
    countdownTimer?.cancel();
    setState(() => myDuration = const Duration(minutes: 1));
    startTimer();
  }

  void setCountDown() {
    if (!mounted) return;
    final seconds = myDuration.inSeconds - 1;
    setState(() {
      if (seconds <= 0) {
        countdownTimer?.cancel();
        myDuration = Duration.zero;
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  // ================= OTP LOGIC =================

  Future<void> verifyOtp() async {
    if (pinController.text.length != 6) {
      _showError("Veuillez entrer un code OTP valide");
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔥 Replace with real API call
      await Future.delayed(const Duration(seconds: 2));

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/bottombar',
        (route) => false,
      );
    } catch (e) {
      _showError("Échec de la vérification OTP");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            backButton(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: fixPadding * 2,
                  vertical: fixPadding * 1.5,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 10),

                  /// Title
                  vertificationText(),

                  const SizedBox(height: 12),

                  /// Subtitle
                  confirmText(),

                  const SizedBox(height: 16),

                  /// Email badge
                  if (savedEmail != null) emailChip(),

                  const SizedBox(height: 32),

                  /// OTP Card
                  otpCard(),

                  const SizedBox(height: 24),

                  /// Timer
                  timer(minutes, seconds),

                  const SizedBox(height: 32),

                  /// Verify button
                  verifyButton(),

                  const SizedBox(height: 20),

                  /// Resend
                  resendText(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGETS =================

  Widget otpCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: fixPadding * 2,
        horizontal: fixPadding,
      ),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            getTranslation(context, 'Enter code'),
            style: semibold16BlackText,
          ),
          const SizedBox(height: 16),
          otpField(),
        ],
      ),
    );
  }

  Widget emailChip() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          savedEmail!,
          style: semibold14Primary.copyWith(letterSpacing: 0.2),
        ),
      ),
    );
  }

  Widget otpField() {
    return Form(
      key: formKey,
      child: Pinput(
        controller: pinController,
        focusNode: focusNode,
        length: 6,
        defaultPinTheme: _pinTheme(),
        focusedPinTheme: _focusedPinTheme(),
        submittedPinTheme: _focusedPinTheme(),
        cursor: Container(
          width: 2,
          height: 20,
          color: primaryColor,
        ),
      ),
    );
  }

  PinTheme _pinTheme() => PinTheme(
        width: 50,
        height: 50,
        textStyle: medium22Primary,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: blackColor.withOpacity(0.15), blurRadius: 6)
          ],
        ),
      );

  PinTheme _focusedPinTheme() => _pinTheme().copyWith(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryColor),
          boxShadow: [
            BoxShadow(color: primaryColor.withOpacity(0.25), blurRadius: 6)
          ],
        ),
      );

  Widget verifyButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isLoading ? 0.7 : 1,
      child: InkWell(
        onTap: isLoading ? null : verifyOtp,
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(fixPadding * 1.4),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.25),
                blurRadius: 8,
              )
            ],
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  getTranslation(context, 'otp.verify'),
                  style: bold18White,
                ),
        ),
      ),
    );
  }

  Widget resendText() {
    return Text.rich(
      TextSpan(
        text: getTranslation(context, "otp.didn't_text"),
        style: semibold14BlackText,
        children: [
          const TextSpan(text: ' '),
          TextSpan(
            text: getTranslation(context, 'otp.resend_OTP'),
            style: bold16Primary,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (myDuration == Duration.zero) {
                  resetTimer();
                }
              },
          )
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget timer(String minutes, String seconds) {
    return Center(
      child: Text(
        "$minutes : $seconds",
        style: semibold14Primary,
      ),
    );
  }

  Widget vertificationText() => Text(
        getTranslation(context, 'otp.OTP_verification'),
        style: bold22BlackText,
        textAlign: TextAlign.center,
      );

  Widget confirmText() {
    final email = savedEmail ?? "";

    return Text.rich(
      TextSpan(
        text: "Nous avons envoyé un code de vérification à\n",
        style: semibold15Grey,
        children: [
          TextSpan(
            text: email,
            style: semibold15Grey.copyWith(
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget backButton(BuildContext context) => Row(
        children: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ],
      );
}
