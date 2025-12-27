import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qways/constant/apiservice.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();
    _fillRandomData();
  }

  void _fillRandomData() {
    final random = Random();
    final names = ['Alice', 'Bob', 'Charlie', 'David', 'Eva', 'Frank'];
    final randomName = names[random.nextInt(names.length)];

    nameController.text = randomName;
    emailController.text =
        '${randomName.toLowerCase()}${random.nextInt(999)}@example.com';
    mobileController.text = '9${100000000 + random.nextInt(900000000)}';
    passwordController.text = 'Test1234';
  }

  bool _isValidPhone(String phone) {
    return phone.length >= 9 &&
        phone.length <= 15 &&
        int.tryParse(phone) != null;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  bool _validateInputs(BuildContext context) {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final mobile = mobileController.text.trim();

    if (name.length < 3) {
      _showError(context, "Le nom doit contenir au moins 3 caractères");
      return false;
    }

    if (!_emailRegex.hasMatch(email)) {
      _showError(context, "Adresse email invalide");
      return false;
    }

    if (password.length < 6) {
      _showError(context, "Mot de passe trop faible (min 6 caractères)");
      return false;
    }

    if (!_isValidPhone(mobile)) {
      _showError(context, "Numéro de téléphone invalide");
      return false;
    }

    return true;
  }

  Future<void> registerUser(BuildContext context) async {
    if (!_validateInputs(context)) return;

    setState(() => isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final firebaseId = userCredential.user?.uid;
      if (firebaseId == null) {
        throw Exception("Firebase UID null");
      }

      final body = {
        "firebase_id": firebaseId,
        "type": "email",
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "mobile": mobileController.text.trim(),
        "fcm_id": "",
        "status": 1,
      };

      final response =
          await ApiService.post(endpoint: 'user_signup', body: body);
      final data = ApiService.decodeResponse(response);

      // Check if we got a token, regardless of 'error' flag/status code sometimes
      final responseData = data["data"];

      if (responseData != null && responseData["api_token"] != null) {
        final prefs = await SharedPreferences.getInstance();
        final token = responseData["api_token"].toString();
        await prefs.setString("api_token", token);

        // ✅ Save user credentials & profile data
        if (responseData["id"] != null) await prefs.setString("user_id", responseData["id"].toString());
        await prefs.setString("user_name", nameController.text.trim());
        await prefs.setString("user_email", emailController.text.trim());
        await prefs.setString("user_password", passwordController.text.trim());
        await prefs.setString("user_mobile", mobileController.text.trim());
        
        if (responseData["profile"] != null) await prefs.setString("profile_img", responseData["profile"].toString());
        if (responseData["coins"] != null) await prefs.setString("user_coins", responseData["coins"].toString());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie 🎉')),
        );

        Navigator.pushNamed(context, '/bottombar');
      } else {
        final msg = data["message"] ?? "Erreur lors de l'inscription";
        print("Register Error: $data");
        _showError(context, getApiMessage(data) ?? msg.toString());
      }
    } on FirebaseAuthException catch (e) {
      _showError(context, e.message ?? "Erreur Firebase");
    } catch (e) {
      _showError(context, "Erreur inattendue");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            backButton(context),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
                children: [
                  topImage(size),
                  heightSpace,
                  rideText(context),
                  heightSpace,
                  registerText(context),
                  height5Space,
                  welcomeText(context),
                  heightSpace,
                  nameField(context),
                  heightSpace,
                  emailField(context),
                  heightSpace,
                  passwordField(context),
                  heightSpace,
                  mobileField(context),
                  heightSpace,
                  registerButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget registerButton(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isLoading ? 0.7 : 1,
      child: InkWell(
        onTap: isLoading ? null : () => registerUser(context),
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(fixPadding * 1.4),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.25),
                blurRadius: 6,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  getTranslation(context, 'register.register'),
                  style: bold18White,
                ),
        ),
      ),
    );
  }

  Widget inputField(
    BuildContext context, {
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
            borderRadius: BorderRadius.circular(10),
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

  Widget nameField(BuildContext context) => inputField(
        context,
        label: getTranslation(context, 'register.name'),
        hint: getTranslation(context, 'register.enter_name'),
        icon: Icons.person_outline,
        controller: nameController,
        keyboardType: TextInputType.name,
      );

  Widget emailField(BuildContext context) => inputField(
        context,
        label: getTranslation(context, 'register.email_address'),
        hint: getTranslation(context, 'register.enter_email'),
        icon: Icons.email_outlined,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
      );

  Widget passwordField(BuildContext context) => inputField(
        context,
        label: getTranslation(context, 'Password'),
        hint: getTranslation(context, 'Please use a strong password'),
        icon: Icons.lock_outline,
        controller: passwordController,
        obscureText: true,
      );

  Widget mobileField(BuildContext context) => inputField(
        context,
        label: getTranslation(context, 'register.mobile_number'),
        hint: getTranslation(context, 'register.enter_number'),
        icon: Icons.phone_android,
        controller: mobileController,
        keyboardType: TextInputType.phone,
      );

  Widget welcomeText(context) => Text(
        getTranslation(context, 'register.welcome_text'),
        style: bold15Grey,
        textAlign: TextAlign.center,
      );

  Widget registerText(context) => Text(
        getTranslation(context, 'register.register'),
        style: bold22BlackText,
        textAlign: TextAlign.center,
      );

  Widget rideText(context) => Text(
        getTranslation(context, 'register.ride_text'),
        style: bold22BlueText,
        textAlign: TextAlign.center,
      );

  Widget topImage(Size size) => Center(
        child: Image.asset(
          "assets/auth/image.png",
          height: size.height * 0.18,
        ),
      );
}
