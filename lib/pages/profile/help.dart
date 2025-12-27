import 'package:qways/localization/localization_const.dart';
import 'package:qways/pages/bottomNavigation/bottom_navigation.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: whiteColor,
        foregroundColor: black2FColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          getTranslation(context, 'help.help_support'),
          style: bold18BlackText,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
            left: fixPadding * 2.0,
            right: fixPadding * 2.0,
            bottom: fixPadding * 2.0,
            top: fixPadding),
        children: [
          Image.asset(
            "assets/profile/helpAndSupport.png",
            height: size.height * 0.2,
          ),
          heightSpace,
          heightSpace,
          nameField(),
          heightSpace,
          heightSpace,
          emailField(),
          heightSpace,
          heightSpace,
          messageField(size),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          submitButton(context)
        ],
      ),
    );
  }

  submitButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavigationScreen(index: 3),
          ),
        );
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0, vertical: fixPadding * 1.4),
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
          getTranslation(context, 'help.submit'),
          style: bold18White,
        ),
      ),
    );
  }

  messageField(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'help.message'),
          style: bold16BlackText,
        ),
        heightSpace,
        Container(
          height: size.height * 0.2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.25),
                blurRadius: 6,
              )
            ],
          ),
          child: TextField(
            expands: true,
            maxLines: null,
            minLines: null,
            textAlignVertical: TextAlignVertical.top,
            cursorColor: primaryColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: fixPadding * 2.0, vertical: fixPadding * 1.4),
              hintText: getTranslation(context, 'help.write_here'),
              hintStyle: semibold15Grey,
            ),
          ),
        ),
      ],
    );
  }

  emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'help.email_address'),
          style: bold16BlackText,
        ),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.25),
                blurRadius: 6,
              )
            ],
          ),
          child: TextField(
            cursorColor: primaryColor,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2.0,
              ),
              hintText: getTranslation(context, 'help.enter_email'),
              hintStyle: semibold15Grey,
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
        Text(
          getTranslation(context, 'help.name'),
          style: bold16BlackText,
        ),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.25),
                blurRadius: 6,
              )
            ],
          ),
          child: TextField(
            cursorColor: primaryColor,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2.0,
              ),
              hintText: getTranslation(context, 'help.enter_name'),
              hintStyle: semibold15Grey,
            ),
          ),
        ),
      ],
    );
  }
}
