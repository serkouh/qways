import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppSettingScreen extends StatefulWidget {
  const AppSettingScreen({super.key});

  @override
  State<AppSettingScreen> createState() => _AppSettingScreenState();
}

class _AppSettingScreenState extends State<AppSettingScreen> {
  bool notification = true;
  bool update = true;
  bool policy = false;
  bool dark = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        foregroundColor: black2FColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          getTranslation(context, 'app_settings.app_settings'),
          style: bold18BlackText,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        physics: const BouncingScrollPhysics(),
        children: [
          allownotification(),
          heightSpace,
          heightSpace,
          applicationUpdate(),
          heightSpace,
          heightSpace,
          policyAndCommunity(),
          heightSpace,
          heightSpace,
          theme(),
        ],
      ),
    );
  }

  theme() {
    return settingWidget(
      getTranslation(context, 'app_settings.dark_mode'),
      "Lorem ipsum dolor sit amet, consectetur adipiscing Senectus pellentesque justo, quis varius dictumst",
      dark,
      (value) {
        setState(() {
          dark = !dark;
        });
      },
    );
  }

  policyAndCommunity() {
    return settingWidget(
      getTranslation(context, 'app_settings.policy_community'),
      "Lorem ipsum dolor sit amet, consectetur adipiscing Senectus pellentesque justo, quis varius dictumst",
      policy,
      (value) {
        setState(() {
          policy = !policy;
        });
      },
    );
  }

  applicationUpdate() {
    return settingWidget(
      getTranslation(context, 'app_settings.application_update'),
      "Lorem ipsum dolor sit amet, consectetur adipiscing Senectus pellentesque justo, quis varius dictumst",
      update,
      (value) {
        setState(() {
          update = !update;
        });
      },
    );
  }

  allownotification() {
    return settingWidget(
      getTranslation(context, 'app_settings.allow_notification'),
      "Lorem ipsum dolor sit amet, consectetur adipiscing Senectus pellentesque justo, quis varius dictumst",
      notification,
      (value) {
        setState(() {
          notification = !notification;
        });
      },
    );
  }

  settingWidget(title, description, value, Function(bool) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: bold16BlackText,
              ),
            ),
            CupertinoSwitch(
                activeColor: primaryColor,
                trackColor: greyB4Color,
                value: value,
                onChanged: onChanged)
          ],
        ),
        Text(
          description,
          style: semibold14Grey,
        )
      ],
    );
  }
}
