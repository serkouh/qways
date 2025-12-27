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
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      nameController.text = (prefs.getString('user_name') ?? '').trim();
      emailController.text = (prefs.getString('user_email') ?? '').trim();
      numberController.text = (prefs.getString('user_mobile') ?? '').trim();
      profileImg = prefs.getString('profile_img') ?? '';

      // Fetch fresh data
      final res = await ApiService.post(
          endpoint: 'get_geo_quiz_profile', withAuth: true);
      if (res.statusCode == 200) {
        final decoded = ApiService.decodeResponse(res);
        if (decoded is Map && decoded['data'] != null) {
          final data = decoded['data'];
          
          if (mounted) {
            setState(() {
              nameController.text = data['name'] ?? nameController.text;
              emailController.text = data['email'] ?? emailController.text;
              numberController.text = data['mobile'] ?? numberController.text;
              profileImg = data['profile_img'] ?? profileImg;
              userId = data['id']?.toString();
            });
          }
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ... (build method remains same until _showImagePickerSheet)

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
        // Refresh profile to get new image URL
        _loadInitialData(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile image updated!"), backgroundColor: Colors.green),
        );
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
      setState(() => _isSaving = false);
    }
  }
}
