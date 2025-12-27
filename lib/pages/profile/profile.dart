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
      if (mounted) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      }

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
        if (mounted) {
          setState(() {
            _profileStats = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("⚠️ Error fetching profile: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: f4Color, // Light grey background
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _hasError
              ? _buildErrorView()
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 220.0,
                      floating: false,
                      pinned: true,
                      backgroundColor: primaryColor,
                      automaticallyImplyLeading: false,
                      flexibleSpace: FlexibleSpaceBar(
                        background: _buildHeader(),
                      ),
                      systemOverlayStyle: SystemUiOverlayStyle.light,
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(fixPadding * 2.0),
                        child: Column(
                          children: [
                            _buildStatsGrid(),
                            heightSpace,
                            heightSpace,
                            _buildMenuSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade300, size: 60),
          heightSpace,
          const Text("Could not load profile", style: bold18BlackText),
          heightSpace,
          ElevatedButton(
            onPressed: _fetchProfileData,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text("Retry", style: bold16White),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final name = _userInfo?["name"] ?? "User";
    final email = _userInfo?["email"] ?? "";
    final profileImg = _userInfo?["profile_img"];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, Color(0xFF6A9BF5)], // Adjust gradient
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
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
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/editProfile')
                          .then((_) => _fetchProfileData());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LineIcons.edit,
                          size: 18, color: primaryColor),
                    ),
                  ),
                )
              ],
            ),
            heightSpace,
            Text(name, style: bold20White),
            const SizedBox(height: 4),
            Text(email, style: medium14White.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_profileStats == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(fixPadding * 1.5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            LineIcons.trophy,
            "${_profileStats?['data']?['total_quizzes_played'] ?? _profileStats?['total_quizzes_played'] ?? 0}",
            "Quizzes",
            Colors.orange,
          ),
          Container(height: 40, width: 1, color: greyColor.withOpacity(0.3)),
          _buildStatItem(
            LineIcons.road,
            "${_profileStats?['data']?['total_distance_km'] ?? _profileStats?['total_distance_km'] ?? 0}",
            "KM",
            Colors.blue,
          ),
          Container(height: 40, width: 1, color: greyColor.withOpacity(0.3)),
          _buildStatItem(
            LineIcons.bullseye,
            "${_profileStats?['data']?['accuracy_percentage'] ?? _profileStats?['accuracy_percentage'] ?? 0}%",
            "Accuracy",
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 5),
        Text(value, style: bold18BlackText),
        Text(label, style: semibold12Grey),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuCard([
          _buildMenuItem(Icons.history, "Quiz History", '/ridehistory'),
          _buildMenuItem(
              CupertinoIcons.person_3,
              getTranslation(context, 'profile.refer_earn'),
              '/referAndEarn'),
        ]),
        heightSpace,
        _buildMenuCard([
          _buildMenuItem(
              CupertinoIcons.globe,
              getTranslation(context, 'profile.language'),
              '/language'),
          _buildMenuItem(
              CupertinoIcons.gear_alt,
              getTranslation(context, 'profile.app_settings'),
              '/appSettings'),
        ]),
        heightSpace,
        _buildMenuCard([
          _buildMenuItem(Icons.privacy_tip_outlined,
              getTranslation(context, 'profile.privacy_policy'), '/privacyPolicy'),
          _buildMenuItem(Icons.list_alt,
              getTranslation(context, 'profile.terms_condition'), '/termsAndCondition'),
          _buildMenuItem(
              Icons.help_outline,
              getTranslation(context, 'profile.help_support'),
              '/help'),
        ]),
        heightSpace,
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String route) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            Navigator.pushNamed(context, route);
          },
          leading: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          title: Text(title, style: bold16BlackText),
          trailing: const Icon(Icons.arrow_forward_ios,
              size: 16, color: greyColor),
        ),
        if (title != getTranslation(context, 'profile.help_support') && // Last items in blocks
            title != getTranslation(context, 'profile.refer_earn') &&
            title != getTranslation(context, 'profile.app_settings'))
          const Divider(height: 1, indent: 60),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _showLogoutDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: const Center(
          child: Text(
            "Logout",
            style: TextStyle(
                color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: greyColor))),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
