import 'dart:convert';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qways/constant/apiservice.dart';
import 'package:line_icons/line_icons.dart';

import 'package:image_picker/image_picker.dart'; // Add import

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
  final ImagePicker _picker = ImagePicker(); // Picker instance

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      // Load local content first to be fast
      final localName = prefs.getString('user_name');
      final localEmail = prefs.getString('user_email');
      final localMobile = prefs.getString('user_mobile');
      final localImg = prefs.getString('profile_img');

      if (localName != null) nameController.text = localName;
      if (localEmail != null) emailController.text = localEmail;
      if (localMobile != null) numberController.text = localMobile;
      
      setState(() {
        profileImg = localImg;
      });

      // Fetch fresh data from server
      final res = await ApiService.post(
          endpoint: 'get_geo_quiz_profile', withAuth: true);
          
      if (res.statusCode == 200) {
        final decoded = ApiService.decodeResponse(res);
        if (decoded is Map && decoded['data'] != null) {
          final data = decoded['data'];
          
          if (mounted) {
            setState(() {
              // Ensure we don't overwrite user edits if they started typing (though unrelated here since we just loaded)
              // But for "auto-fill" we want to enforce server data
              nameController.text = data['name'] ?? nameController.text;
              emailController.text = data['email'] ?? emailController.text;
              numberController.text = data['mobile'] ?? numberController.text;
              
              // Add timestamp to bust cache if it's the same URL
              String? newImg = data['profile_img'];
              if (newImg != null && newImg.isNotEmpty) {
                 if (!newImg.contains('?')) {
                   newImg = "$newImg?t=${DateTime.now().millisecondsSinceEpoch}";
                 } else {
                   newImg = "$newImg&t=${DateTime.now().millisecondsSinceEpoch}";
                 }
              }
              profileImg = newImg ?? profileImg;
              userId = data['id']?.toString();
            });
            
            // Sync fresh data to prefs
            await prefs.setString('user_name', nameController.text);
            await prefs.setString('user_email', emailController.text);
            await prefs.setString('user_mobile', numberController.text);
            if (profileImg != null) {
               // Store the raw URL without timestamp in prefs usually, but for display we need bust. 
               // Let's just store what we got.
               await prefs.setString('profile_img', data['profile_img'] ?? '');
            }
          }
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ... (build method, etc.)

  void _showImagePickerSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
        margin: const EdgeInsets.all(fixPadding),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(fixPadding * 2.0),
              child: Text(
                getTranslation(context, 'edit_profile.change_profile_photo'),
                style: semibold18BlackText,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionEvent(
                  const Color(0xFF1E4799),
                  Icons.camera_alt,
                  getTranslation(context, 'edit_profile.camera'),
                  ImageSource.camera,
                ),
                _buildOptionEvent(
                  Colors.green,
                  Icons.photo_library,
                  getTranslation(context, 'edit_profile.gallery'),
                  ImageSource.gallery,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionEvent(
      Color color, IconData icon, String title, ImageSource source) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _pickImage(source);
      },
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(title, style: medium14BlackText),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        await _uploadImage(image.path);
      }
    } catch (e) {
      print("Image picking error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick image")),
      );
    }
  }

  Future<void> _uploadImage(String filePath) async {
    setState(() => _isSaving = true);
    try {
      final res = await ApiService.postMultipart(
        endpoint: 'upload_profile_image',
        filePath: filePath,
        withAuth: true,
      );

      final decoded = ApiService.decodeResponse(res);
      if (res.statusCode == 200 && decoded['error'] == false) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile image updated!"), backgroundColor: Colors.green),
        );
        
        // Reload data to get the new image URL and refresh UI
        // This will now apply the cache-busting timestamp
        await _loadInitialData();
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(getApiMessage(decoded)), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload image"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: f4Color,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: f4Color,
        foregroundColor: black2FColor,
        centerTitle: true,
        title: Text(
          getTranslation(context, 'edit_profile.edit_profile'),
          style: bold18BlackText,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(fixPadding * 2.0),
              child: Column(
                children: [
                  _buildProfileImage(),
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  _buildTextField(
                    controller: nameController,
                    label: getTranslation(context, 'edit_profile.name'),
                    hint: getTranslation(context, 'edit_profile.enter_name'),
                    icon: LineIcons.user,
                  ),
                  heightSpace,
                  heightSpace,
                  _buildTextField(
                    controller: emailController,
                    label: getTranslation(context, 'edit_profile.email_address'),
                    hint: getTranslation(context, 'edit_profile.enter_email'),
                    icon: LineIcons.envelope,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  heightSpace,
                  heightSpace,
                  _buildTextField(
                    controller: numberController,
                    label: getTranslation(context, 'edit_profile.mobile_number'),
                    hint: getTranslation(context, 'edit_profile.enter_number'),
                    icon: LineIcons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  _buildUpdateButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: whiteColor,
              border: Border.all(color: whiteColor, width: 4),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              image: DecorationImage(
                image: profileImg != null && profileImg!.isNotEmpty
                    ? NetworkImage(profileImg!)
                    : const AssetImage("assets/profile/userImage.png")
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _showImagePickerSheet,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                  border: Border.all(color: whiteColor, width: 2),
                ),
                child: const Icon(Icons.camera_alt, color: whiteColor, size: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: bold16BlackText),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: TextField(
            controller: controller,
            cursorColor: primaryColor,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: greyColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: fixPadding * 1.5, vertical: 15),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return InkWell(
      onTap: _isSaving ? null : _saveProfile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        alignment: Alignment.center,
        child: _isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                getTranslation(context, 'edit_profile.update'),
                style: bold18White,
              ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
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
        // Update Local Prefs
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', nameController.text.trim());
        await prefs.setString('user_email', emailController.text.trim());
        await prefs.setString('user_mobile', numberController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(getApiMessage(decoded) ?? 'Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        final message = decoded['message']?.toString() ?? "Failed to update";
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Helpers located below build method
  // ...

}
