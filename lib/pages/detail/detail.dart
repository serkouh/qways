import 'package:qways/localization/localization_const.dart';
import 'package:qways/pages/bottomNavigation/bottom_navigation.dart';
import 'package:qways/pages/profile/language.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: whiteColor,
        foregroundColor: black2FColor,
        shadowColor: shadowColor.withOpacity(0.3),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        titleSpacing: 0,
        toolbarHeight: 65,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "City rider BK2252",
              style: bold18BlackText,
            ),
            heightBox(3.0),
            Text(
              getTranslation(context, 'detail.ready_go'),
              style: bold15Grey,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: yellowColor,
                  size: 22,
                ),
                widthBox(3.0),
                const Text(
                  "4.5",
                  style: bold16BlackText,
                )
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          scooterDetail(size, context),
          title(getTranslation(context, 'detail.rent')),
          rentDetail(context),
          title(getTranslation(context, 'detail.parking_rules')),
          parkingRuleDetail(context)
        ],
      ),
      bottomNavigationBar: bottomButtonBar(context),
    );
  }

  bottomButtonBar(context) {
    return Container(
      padding: const EdgeInsets.only(
          left: fixPadding * 2.0,
          right: fixPadding * 2.0,
          top: fixPadding,
          bottom: fixPadding * 2.0),
      color: whiteColor,
      width: double.maxFinite,
      child: Row(
        children: [
          unlockNowButton(context),
          widthSpace,
          widthSpace,
          getDirectionButton(context)
        ],
      ),
    );
  }

  getDirectionButton(context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/direction');
        },
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(
              vertical: fixPadding * 1.4, horizontal: fixPadding),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.25),
                blurRadius: 6,
              )
            ],
          ),
          child: Text(
            getTranslation(context, 'detail.get_direction'),
            style: bold18Primary,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  unlockNowButton(context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomNavigationScreen(index: 4),
            ),
          );
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
          child: Text(
            getTranslation(context, 'detail.unlock_now'),
            style: bold18White,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  parkingRuleDetail(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 2.0, vertical: fixPadding),
      child: Column(
        children: [
          ruleWidget("assets/detail/parking.png",
              getTranslation(context, 'detail.park_in_cityzone')),
          ruleWidget("assets/detail/noParking.png",
              getTranslation(context, 'detail.do_not_park')),
        ],
      ),
    );
  }

  ruleWidget(icon, text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: fixPadding),
      child: Row(
        children: [
          Image.asset(
            icon,
            height: 25,
            width: 25,
            color: primaryColor,
          ),
          widthSpace,
          Expanded(
            child: Text(
              text,
              style: semibold16BlackText,
            ),
          )
        ],
      ),
    );
  }

  rentDetail(context) {
    return Padding(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: languageValue == 4
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: rentWidget(
                  getTranslation(context, 'detail.fixed_rent'), "\$5.00"),
            ),
          ),
          verticalDivider(),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: rentWidget(
                  getTranslation(context, 'detail.per_km'), "\$0.50"),
            ),
          ),
          verticalDivider(),
          Expanded(
            child: Align(
              alignment: languageValue == 4
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: rentWidget(
                  getTranslation(context, 'detail.pause_min'), "\$0.10"),
            ),
          ),
        ],
      ),
    );
  }

  verticalDivider() {
    return Container(
      height: 42,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: fixPadding),
      color: greyB4Color,
    );
  }

  rentWidget(title, detail) {
    return Column(
      children: [
        Text(
          title,
          style: bold16Primary,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          detail,
          style: bold16BlackText,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }

  title(title) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 7.0, horizontal: fixPadding * 2.0),
      width: double.maxFinite,
      color: f0Color,
      child: Text(
        title,
        style: bold16BlackText,
      ),
    );
  }

  scooterDetail(Size size, context) {
    return Padding(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Image.asset(
                  "assets/detail/image.png",
                  width: double.maxFinite,
                ),
              ),
              widthSpace,
              widthSpace,
              Column(
                children: [
                  scooterDetailWidget(size, "assets/detail/batteryIcon.png",
                      getTranslation(context, 'detail.battery_level'), "90%"),
                  heightSpace,
                  heightSpace,
                  scooterDetailWidget(size, "assets/detail/rangeIcon.png",
                      getTranslation(context, 'detail.range_upto'), "30-35 km")
                ],
              )
            ],
          ),
          heightSpace,
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. Fermsvulputate sit tincidunt ac euismod. Eget mauris in nasceadipiscing urna amet quam amet. Sem faucibus tempus tincidunt tortor aliquam ultrices mollis nunc posuere. Sagittis ",
            style: semibold14Grey,
          )
        ],
      ),
    );
  }

  scooterDetailWidget(Size size, image, title, detail) {
    return Container(
      width: size.width * 0.31,
      padding: const EdgeInsets.all(fixPadding),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            image,
            height: 25,
          ),
          heightSpace,
          Text(
            title,
            style: bold16Primary,
            overflow: TextOverflow.ellipsis,
          ),
          height5Space,
          Text(
            detail,
            style: bold16BlackText,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
