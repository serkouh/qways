import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qways/constant/apiservice.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, dynamic>? _profileStats;
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString("user_name") ?? "User";
      final email = prefs.getString("user_email") ?? "user@email.com";
      final profileImg = prefs.getString("profile_img") ?? "";

      _userInfo = {
        "name": name,
        "email": email,
        "profile_img": profileImg,
      };

      final response = await ApiService.post(
        endpoint: "get_geo_quiz_profile",
        withAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _profileStats = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      print("⚠️ Error fetching profile: $e");
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        foregroundColor: black2FColor,
        title: Text(
          getTranslation(context, 'profile.profile'),
          style: bold20BlackText,
        ),
        elevation: 0,
        backgroundColor: whiteColor,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: redColor, size: 50),
                      const SizedBox(height: 10),
                      const Text("Failed to load profile data"),
                      ElevatedButton(
                        onPressed: _fetchProfileData,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: fixPadding * 9.0),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    userprofileAndEdit(),
                    rideDetails(),
                    heightSpace,
                    heightSpace,
                    menuSection(),
                  ],
                ),
    );
  }

  // 📊 Profile stats section
  rideDetails() {
    if (_profileStats == null) return const SizedBox();

    return Container(
      color: f4Color,
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.5, horizontal: fixPadding),
      child: Row(
        children: [
          rideDetailWidget(
            "assets/profile/bicycle.png",
            getTranslation(context, 'profile.ride_taken'),
            "${_profileStats?['total_quizzes_played'] ?? 0}",
          ),
          verticalDivider(),
          rideDetailWidget(
            "assets/profile/location-current.png",
            getTranslation(context, 'profile.distance'),
            "${(_profileStats?['total_distance_km'] ?? 0).toString()} km",
          ),
          verticalDivider(),
          rideDetailWidget(
            "assets/profile/calories.png",
            getTranslation(context, 'profile.accuracy'),
            "${(_profileStats?['accuracy_percentage'] ?? 0).toString()}%",
          ),
        ],
      ),
    );
  }

  userprofileAndEdit() {
    final name = _userInfo?["name"] ?? "Guest";
    final email = _userInfo?["email"] ?? "";
    final profileImg = _userInfo?["profile_img"];

    return Container(
      padding: const EdgeInsets.only(
          left: fixPadding * 2.0,
          right: fixPadding * 2.0,
          bottom: fixPadding * 2.0,
          top: fixPadding / 2),
      width: double.maxFinite,
      color: whiteColor,
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: whiteColor,
              border: Border.all(color: whiteColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.25),
                  blurRadius: 6,
                )
              ],
              image: DecorationImage(
                image: profileImg != null && profileImg.isNotEmpty
                    ? NetworkImage(profileImg)
                    : const AssetImage("assets/home/userImage.png")
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          widthSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: bold16BlackText),
                Text(email, style: semibold14Grey),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/editProfile');
            },
            icon: const Icon(LineIcons.edit, color: black2FColor),
          ),
        ],
      ),
    );
  }

  menuSection() {
    return Container(
      color: f4Color,
      child: Column(
        children: [
          height5Space,
          listTileWidget(Icons.directions_bike,
              getTranslation(context, 'profile.ride_history'), () {
            Navigator.pushNamed(context, '/ridehistory');
          }),
          listTileWidget(CupertinoIcons.person_3,
              getTranslation(context, 'profile.refer_earn'), () {
            Navigator.pushNamed(context, '/referAndEarn');
          }),
          listTileWidget(
              CupertinoIcons.globe, getTranslation(context, 'profile.language'),
              () {
            Navigator.pushNamed(context, '/language');
          }),
          listTileWidget(CupertinoIcons.gear_alt,
              getTranslation(context, 'profile.app_settings'), () {
            Navigator.pushNamed(context, '/appSettings');
          }),
          listTileWidget(CupertinoIcons.chat_bubble_2,
              getTranslation(context, 'profile.FAQs'), () {
            Navigator.pushNamed(context, '/FAQs');
          }),
          listTileWidget(Icons.privacy_tip_outlined,
              getTranslation(context, 'profile.privacy_policy'), () {
            Navigator.pushNamed(context, '/privacyPolicy');
          }),
          listTileWidget(Icons.list_alt,
              getTranslation(context, 'profile.terms_condition'), () {
            Navigator.pushNamed(context, '/termsAndCondition');
          }),
          listTileWidget(Icons.help_outline,
              getTranslation(context, 'profile.help_support'), () {
            Navigator.pushNamed(context, '/help');
          }),
          logoutTile(),
          height5Space,
        ],
      ),
    );
  }

  listTileWidget(IconData icon, String title, Function() onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      leading: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFCFCFC),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      minLeadingWidth: 0,
      title: Text(title, style: bold16BlackText),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: black2FColor, size: 18),
    );
  }

  rideDetailWidget(image, title, text) {
    return Expanded(
      child: Column(
        children: [
          Image.asset(image, height: 35),
          height5Space,
          Text(title, style: bold16Primary, overflow: TextOverflow.ellipsis),
          heightBox(3),
          Text(text, style: bold16BlackText, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  verticalDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: fixPadding),
      height: 80,
      width: 1,
      color: greyB4Color,
    );
  }

  logoutTile() {
    return ListTile(
      onTap: () => logoutDialog(),
      contentPadding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      leading: const Icon(Icons.logout, color: redColor),
      title: Text(getTranslation(context, 'profile.logout'), style: bold16Red),
    );
  }

  logoutDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Do you really want to log out?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
            child: const Text("Logout", style: TextStyle(color: redColor)),
          ),
        ],
      ),
    );
  }
}
