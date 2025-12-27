import 'dart:convert';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qways/constant/apiservice.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? profileImg;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      nameController.text = prefs.getString('user_name') ?? '';
      emailController.text = prefs.getString('user_email') ?? '';
      numberController.text = prefs.getString('user_mobile') ?? '';
      profileImg = prefs.getString('profile_img') ?? '';

      // Try fetching server profile for freshest data
      final res = await ApiService.post(
          endpoint: 'get_geo_quiz_profile', withAuth: true);
      if (res.statusCode == 200) {
        final decoded = ApiService.decodeResponse(res);
        if (decoded is Map && decoded['data'] != null) {
          final data = decoded['data'];
          nameController.text = data['name'] ?? nameController.text;
          emailController.text = data['email'] ?? emailController.text;
          numberController.text = data['mobile'] ?? numberController.text;
          profileImg = data['profile_img'] ?? profileImg;
          userId = data['id']?.toString();
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: whiteColor,
        foregroundColor: black2FColor,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          getTranslation(context, 'edit_profile.edit_profile'),
          style: bold18BlackText,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(
                left: fixPadding * 2.0,
                right: fixPadding * 2.0,
                bottom: fixPadding * 2.0,
                top: fixPadding,
              ),
              physics: const BouncingScrollPhysics(),
              children: [
                userProfile(size),
                heightSpace,
                heightSpace,
                heightSpace,
                nameField(),
                heightSpace,
                heightSpace,
                mobileField(),
                heightSpace,
                heightSpace,
                emailField(),
                heightSpace,
                heightSpace,
                heightSpace,
                heightSpace,
                updateButton(context),
              ],
            ),
    );
  }

  updateButton(BuildContext context) {
    return InkWell(
      onTap: _isSaving
          ? null
          : () async {
              await _saveProfile();
            },
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: fixPadding * 1.4, horizontal: fixPadding * 2.0),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.25),
              blurRadius: 6,
            )
          ],
        ),
        alignment: Alignment.center,
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                getTranslation(context, 'edit_profile.update'),
                style: bold18White,
              ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final body = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'mobile': numberController.text.trim(),
      };

      final res = await ApiService.post(
          endpoint: 'update_profile', body: body, withAuth: true);
      final decoded = ApiService.decodeResponse(res);

      if (res.statusCode == 200 && decoded['error'] == false) {
        // Save to prefs
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', nameController.text.trim());
        await prefs.setString('user_email', emailController.text.trim());
        await prefs.setString('user_mobile', numberController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(getApiMessage(decoded) ?? 'Profile updated')),
          );
          Navigator.pop(context);
        }
      } else {
        final message = decoded['message']?.toString() ?? res.body;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(getApiMessage(decoded) ?? message)));
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget(getTranslation(context, 'edit_profile.email_address')),
        heightSpace,
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(color: blackColor.withOpacity(0.25), blurRadius: 6)
              ]),
          child: TextField(
            cursorColor: primaryColor,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
              border: InputBorder.none,
              hintText: getTranslation(context, 'edit_profile.enter_email'),
            ),
          ),
        )
      ],
    );
  }

  mobileField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget(getTranslation(context, 'edit_profile.mobile_number')),
        heightSpace,
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(color: blackColor.withOpacity(0.25), blurRadius: 6),
            ],
          ),
          child: TextField(
            controller: numberController,
            cursorColor: primaryColor,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
              hintText: getTranslation(context, 'edit_profile.enter_number'),
            ),
          ),
        ),
      ],
    );
  }

  nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget(getTranslation(context, 'edit_profile.name')),
        heightSpace,
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.25),
                  blurRadius: 6,
                ),
              ]),
          child: TextField(
            controller: nameController,
            cursorColor: primaryColor,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
              hintText: getTranslation(context, 'edit_profile.enter_name'),
            ),
          ),
        )
      ],
    );
  }

  textWidget(String title) {
    return Text(
      title,
      style: bold16BlackText,
    );
  }

  userProfile(Size size) {
    return Center(
      child: SizedBox(
        height: size.height * 0.145,
        width: size.height * 0.14,
        child: Stack(
          children: [
            Container(
              height: size.height * 0.14,
              width: size.height * 0.14,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage("assets/profile/userImage.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return Container(
                        padding: const EdgeInsets.all(fixPadding * 2.0),
                        width: double.maxFinite,
                        decoration: const BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10.0),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getTranslation(
                                  context, 'edit_profile.change_profile_photo'),
                              style: semibold18BlackText,
                            ),
                            heightSpace,
                            heightSpace,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                changePhotoWidget(
                                    context,
                                    const Color(0xFF1E4799),
                                    Icons.camera_alt,
                                    getTranslation(
                                        context, 'edit_profile.camera')),
                                changePhotoWidget(
                                    context,
                                    greenColor,
                                    Icons.photo,
                                    getTranslation(
                                        context, 'edit_profile.gallery')),
                                changePhotoWidget(
                                    context,
                                    redColor,
                                    CupertinoIcons.trash_fill,
                                    getTranslation(
                                        context, 'edit_profile.remove')),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  height: size.height * 0.05,
                  width: size.height * 0.05,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: whiteColor,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  changePhotoWidget(
      BuildContext context, Color color, IconData icon, String title) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.25),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: whiteColor,
            ),
          ),
          heightSpace,
          Text(
            title,
            style: medium16BlackText,
          )
        ],
      ),
    );
  }
}
