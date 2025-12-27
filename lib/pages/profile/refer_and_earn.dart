import 'package:dotted_border/dotted_border.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class ReferAndEarnScreen extends StatelessWidget {
  const ReferAndEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        foregroundColor: black2FColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: false,
        title: Text(
          getTranslation(context, 'refer_and_earn.refer_and_earn'),
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
          topImage(size),
          heightSpace,
          heightSpace,
          heightSpace,
          title(context),
          heightSpace,
          contentText(context),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          linkBox(),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          shareLinkTitle(context),
          heightSpace,
          heightSpace,
          socialShareIcons()
        ],
      ),
    );
  }

  contentText(context) {
    return Text(
      getTranslation(context, 'refer_and_earn.content_text'),
      style: semibold16Grey,
      textAlign: TextAlign.center,
    );
  }

  title(context) {
    return Text(
      getTranslation(context, 'refer_and_earn.text'),
      style: bold20BlackText,
      textAlign: TextAlign.center,
    );
  }

  topImage(Size size) {
    return Center(
      child: Image.asset(
        "assets/profile/Refer-a-friend.png",
        height: size.height * 0.27,
      ),
    );
  }

  shareLinkTitle(context) {
    return Text(
      getTranslation(context, 'refer_and_earn.share_via'),
      style: semibold18BlackText,
      textAlign: TextAlign.center,
    );
  }

  socialShareIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        socialWidget(const Color(0xFF4267B2), LineIcons.facebookF),
        widthSpace,
        widthSpace,
        socialWidget(const Color(0xFF25D366), LineIcons.whatSApp),
        widthSpace,
        widthSpace,
        Container(
          height: 50,
          width: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF09433),
                Color(0xFFE6683C),
                Color(0xFFDC2743),
                Color(0xFFCC2366),
                Color(0xFFC01B7F),
                Color(0xFFBC1888),
              ],
            ),
          ),
          child: const Icon(
            LineIcons.instagram,
            color: whiteColor,
            size: 28,
          ),
        ),
      ],
    );
  }

  socialWidget(Color color, IconData icon) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Icon(
        icon,
        color: whiteColor,
        size: 28,
      ),
    );
  }

  linkBox() {
    return DottedBorder(
      padding: EdgeInsets.zero,
      dashPattern: const [6],
      radius: const Radius.circular(10.0),
      borderType: BorderType.RRect,
      strokeWidth: 2,
      color: primaryColor,
      child: Container(
        padding: const EdgeInsets.all(fixPadding * 1.3),
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Text(
                "http://www.referralcityride ride/jkk",
                style: semibold14Primary,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.copy_rounded,
              color: primaryColor,
            )
          ],
        ),
      ),
    );
  }
}
