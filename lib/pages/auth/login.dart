import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:qways/constant/apiservice.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/pages/profile/language.dart';
import 'package:qways/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAgree = true;
  bool isLoading = false;
  DateTime? backPressTime;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController =
      TextEditingController(text: "Test1234");
  final TextEditingController mobileController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _initEmailForDebug();
  }

  Future<void> loginUser() async {
    if ((emailController.text.isEmpty || passwordController.text.isEmpty) &&
        mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    if (!isAgree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez accepter les conditions d'utilisation")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential? userCredential;
      String loginType = "";

      if (mobileController.text.isNotEmpty) {
        // Mobile login (fallback if Firebase phone auth not implemented)
        loginType = "mobile";
      } else {
        // Email/password login using Firebase
        loginType = "email";
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }

      final firebaseId = userCredential?.user?.uid ??
          "MOBILE_USER_${DateTime.now().millisecondsSinceEpoch}";

      print("✅ Firebase login successful, UID: $firebaseId");

      // Prepare API request
      final Map<String, dynamic> body = {
        "firebase_id": firebaseId,
        "type": loginType,
        "name": "",
        "email": emailController.text.trim(),
        "mobile": mobileController.text.trim(),
        "fcm_id": "",
        "status": 1
      };

      final http.Response response =
          await ApiService.post(endpoint: "user_signup", body: body);
      final data = ApiService.decodeResponse(response);

      print("📩 API Login Response: $data");

      if (response.statusCode == 200 && data["data"] != null) {
        final userData = data["data"];
        if (userData["api_token"] != null) {
          final token = userData["api_token"];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("api_token", token);

          // Save full user profile
          if (userData["id"] != null) await prefs.setString("user_id", userData["id"].toString());
          if (userData["name"] != null) await prefs.setString("user_name", userData["name"].toString());
          if (userData["email"] != null) await prefs.setString("user_email", userData["email"].toString());
          if (userData["mobile"] != null) await prefs.setString("user_mobile", userData["mobile"].toString());
          if (userData["profile"] != null) await prefs.setString("profile_img", userData["profile"].toString());
          if (userData["coins"] != null) await prefs.setString("user_coins", userData["coins"].toString());
          
          print("✅ User data saved: ${userData['name']}, ${userData['email']}");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Connexion réussie ✅")),
          );

          Navigator.pushNamed(context, '/bottombar');
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur: Token manquant")),
          );
        }
      } else {
        final message =
            data["message"] ?? "Échec de la connexion. Veuillez réessayer";
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } on FirebaseAuthException catch (e) {
      print("⚠️ Firebase login error: $e");
      String errorMessage = "Erreur lors de la connexion Firebase";
      if (e.code == 'user-not-found') errorMessage = "Utilisateur non trouvé.";
      if (e.code == 'wrong-password') errorMessage = "Mot de passe incorrect.";

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      print("💥 Unexpected login error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _initEmailForDebug() async {
    if (!kDebugMode) return;

    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString("user_email");

    if (storedEmail != null && storedEmail.isNotEmpty) {
      emailController.text = storedEmail;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(fixPadding * 2.0),
              children: [
                heightSpace,
                heightSpace,
                topImage(size),
                heightSpace,
                rideText(),
                heightSpace,
                loginText(),
                height5Space,
                welcomeText(),
                heightSpace,
                emailField(),
                heightSpace,
                passwordField(),
                heightSpace,
                agreeConditionsText(),
                heightSpace,
                heightSpace,
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : loginButton(),
                heightSpace,
                heightSpace,
                dontHaveAccountText()
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Components Below ---

  Widget loginButton() {
    return InkWell(
      onTap: loginUser,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(fixPadding * 1.4),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.25),
              blurRadius: 6,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'login.login'),
          style: bold18White,
        ),
      ),
    );
  }

  Widget agreeConditionsText() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isAgree = !isAgree;
            });
          },
          child: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0),
              color: isAgree ? blueTextColor : whiteColor,
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.25),
                  blurRadius: 6,
                ),
              ],
              border: Border.all(color: blueTextColor),
            ),
            child: isAgree
                ? const Icon(Icons.done, color: whiteColor, size: 12)
                : null,
          ),
        ),
        widthSpace,
        Expanded(
          child: Text.rich(
            TextSpan(
              text: getTranslation(context, 'login.text1'),
              style: bold12Grey,
              children: [
                const TextSpan(text: ' '),
                TextSpan(
                  text: getTranslation(context, 'login.text2'),
                  style: bold12Primary.copyWith(
                    decoration: TextDecoration.underline,
                    decorationThickness: 1.5,
                  ),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: getTranslation(context, 'login.text3'),
                  style: bold12Grey,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget rideText() {
    return Text(
      getTranslation(context, 'login.ride_text'),
      style: bold22BlueText,
      textAlign: TextAlign.center,
    );
  }

  Widget topImage(Size size) {
    return Center(
      child: Image.asset(
        "assets/auth/image.png",
        height: size.height * 0.18,
      ),
    );
  }

  Widget loginText() {
    return Text(
      getTranslation(context, 'login.ride_text'),
      style: bold22BlackText,
      textAlign: TextAlign.center,
    );
  }

  Widget welcomeText() {
    return Text(
      getTranslation(context, 'login.welcome_text'),
      style: bold15Grey,
      textAlign: TextAlign.center,
    );
  }

  Widget mobileNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'login.mobile_number'),
          style: semibold16BlackText,
        ),
        heightSpace,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: IntlPhoneField(
            controller: mobileController,
            textAlign: languageValue == 4 ? TextAlign.right : TextAlign.left,
            disableLengthCheck: true,
            cursorColor: primaryColor,
            dropdownIcon: const Icon(
              Icons.keyboard_arrow_down_sharp,
              color: black23Color,
            ),
            initialCountryCode: "FR",
            dropdownIconPosition: IconPosition.trailing,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: getTranslation(context, 'Email'),
              hintStyle: semibold16Grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget emailField() {
    return inputField(
      label: getTranslation(context, 'Email'),
      hint: getTranslation(context, 'Email'),
      icon: Icons.email_outlined,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget passwordField() {
    return inputField(
      label: getTranslation(context, 'Password'),
      hint: getTranslation(context, 'Password'),
      icon: Icons.lock_outline,
      controller: passwordController,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
    );
  }

  Widget inputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: semibold16BlackText),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            cursorColor: primaryColor,
            style: const TextStyle(height: 1.4),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon, size: 18),
              hintText: hint,
              hintStyle: semibold16Grey,
            ),
          ),
        ),
      ],
    );
  }

  // Keep all other UI components the same: mobileNumberField(), agreeConditionsText(), loginButton(), topImage(), rideText(), loginText(), welcomeText(), dontHaveAccountText(), etc.

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

  Widget dontHaveAccountText() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Vous n'avez pas encore de compte ? ",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/register'),
            child: Text(
              "Inscrivez-vous",
              style: TextStyle(
                fontSize: 14,
                color: primaryColor,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
