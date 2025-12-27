import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          physics: const BouncingScrollPhysics(),
          children: [
            heightSpace,
            heightSpace,
            heightSpace,
            topImage(size),
            heightSpace,
            heightSpace,
            enjoyText(context),
            heightSpace,
            successText(context),
            heightSpace,
            heightSpace,
            heightSpace,
            heightSpace,
            heightSpace,
            heightSpace,
            startRideButton(context),
          ],
        ),
      ),
    );
  }

  topImage(Size size) {
    return Image.asset(
      "assets/success/Ride a bicycle-pana.png",
      height: size.height * 0.35,
    );
  }

  enjoyText(context) {
    return Text(
      getTranslation(context, 'success.enjoy_text'),
      style: bold25Primary,
      textAlign: TextAlign.center,
    );
  }

  successText(context) {
    return Text(
      getTranslation(context, 'success.your_successfully_unlock'),
      style: semibold18BlackText,
      textAlign: TextAlign.center,
    );
  }

  startRideButton(context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/startRide');
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
            vertical: fixPadding * 1.4, horizontal: fixPadding),
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
        child: Text(
          getTranslation(context, 'success.start_ride'),
          style: bold18White,
        ),
      ),
    );
  }
}
