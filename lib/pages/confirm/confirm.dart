import 'package:dotted_border/dotted_border.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';

class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  int selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          heightSpace,
          heightSpace,
          heightSpace,
          scooterDetail(context, size),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                burnColories(),
                Padding(
                  padding: const EdgeInsets.all(fixPadding * 2.0),
                  child: Row(
                    children: [
                      scooterWidget(
                          "assets/startRide/clock.png",
                          getTranslation(context, 'confirm.ride_time'),
                          "09 : 12 min"),
                      verticalDivider(),
                      scooterWidget(
                          "assets/confirm/timer.png",
                          getTranslation(context, 'confirm.pause_time'),
                          "01 : 15 min"),
                      verticalDivider(),
                      scooterWidget(
                          "assets/startRide/location-current.png",
                          getTranslation(context, 'confirm.travelled'),
                          "3.5km"),
                    ],
                  ),
                ),
                divider(),
                pickupAndDropLocation(),
                divider(),
                paidAmountDetail(),
                divider(),
                heightSpace,
                heightSpace,
                shareExperienceText(),
                giveRateButton(context),
              ],
            ),
          )
        ],
      ),
    );
  }

  giveRateButton(BuildContext context) {
    return InkWell(
      onTap: () {
        giveRateBottomSheet(context);
      },
      child: Container(
        margin: const EdgeInsets.all(fixPadding * 2.0),
        padding: const EdgeInsets.symmetric(
            vertical: fixPadding * 1.4, horizontal: fixPadding),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.25),
              blurRadius: 6,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'confirm.give_rate'),
          style: bold18White,
        ),
      ),
    );
  }

  giveRateBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.only(
                left: fixPadding * 2.0,
                right: fixPadding * 2.0,
                top: fixPadding * 2.0,
                bottom: fixPadding,
              ),
              decoration: const BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20.0),
                ),
              ),
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  Text(
                    getTranslation(context, 'confirm.give_rate'),
                    style: bold20Primary,
                    textAlign: TextAlign.center,
                  ),
                  heightSpace,
                  Text(
                    getTranslation(context, 'confirm.please_text'),
                    style: bold16BlackText,
                    textAlign: TextAlign.center,
                  ),
                  heightSpace,
                  heightSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => _buildStar(index, state),
                    ),
                  ),
                  heightSpace,
                  heightSpace,
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/bottombar');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: fixPadding * 1.4, horizontal: fixPadding),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(5.0),
                        boxShadow: [
                          BoxShadow(
                            color: blackColor.withOpacity(0.25),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        getTranslation(context, 'confirm.submit'),
                        style: bold18White,
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        getTranslation(context, 'confirm.cancel'),
                        style: bold18Primary,
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  _buildStar(index, state) {
    return InkWell(
      onTap: () {
        state(() {
          setState(() {
            selectedIndex = index;
          });
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: fixPadding / 4),
        child: Icon(
          Icons.star_purple500_sharp,
          color: selectedIndex >= index ? primaryColor : greyB4Color,
          size: 40,
        ),
      ),
    );
  }

  shareExperienceText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Text(
        getTranslation(context, 'confirm.share_experience'),
        style: bold16BlackText,
        textAlign: TextAlign.center,
      ),
    );
  }

  paidAmountDetail() {
    return Padding(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Column(
        children: [
          expenseWidget(
              getTranslation(context, 'confirm.fixed_rent'), "\$5.00"),
          heightSpace,
          expenseWidget(getTranslation(context, 'confirm.ride_fare'), "\$4.00"),
          heightSpace,
          expenseWidget(
              getTranslation(context, 'confirm.pause_fare'), "\$0.40"),
          heightSpace,
          Row(
            children: [
              Expanded(
                child: Text(
                  getTranslation(context, 'confirm.paid_wallet'),
                  style: bold16Primary,
                ),
              ),
              widthSpace,
              const Text(
                "\$9.40",
                style: bold16Primary,
              )
            ],
          )
        ],
      ),
    );
  }

  expenseWidget(title, amount) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: bold16Grey,
          ),
        ),
        widthSpace,
        Text(
          amount,
          style: semibold16BlackText,
        )
      ],
    );
  }

  pickupAndDropLocation() {
    return Padding(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Column(
        children: [
          locationWidget(
              Icons.place,
              getTranslation(context, 'confirm.pick_location'),
              "6391 Elgin St. Celina, Delaware 10299",
              "06 : 36 pm"),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
                child: DottedBorder(
                  padding: EdgeInsets.zero,
                  dashPattern: const [1, 4],
                  strokeWidth: 2,
                  color: primaryColor,
                  child: Container(
                    height: 50,
                  ),
                ),
              )
            ],
          ),
          locationWidget(
              Icons.near_me,
              getTranslation(context, 'confirm.drop_location'),
              "1901 Thornridge Cir. Shiloh, Hawaii 81063",
              "08 : 36 pm"),
        ],
      ),
    );
  }

  locationWidget(IconData icon, String title, String address, String time) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: f0Color,
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        widthSpace,
        widthSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: bold16Primary,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                address,
                style: semibold14BlackText,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                time,
                style: semibold14Grey,
              ),
            ],
          ),
        )
      ],
    );
  }

  divider() {
    return DottedBorder(
      padding: EdgeInsets.zero,
      color: primaryColor,
      dashPattern: const [2.5],
      child: Container(),
    );
  }

  verticalDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: fixPadding),
      height: 70,
      width: 1,
      color: greyB4Color,
    );
  }

  scooterWidget(icon, title, detail) {
    return Expanded(
      child: Column(
        children: [
          Image.asset(
            icon,
            height: 30,
          ),
          height5Space,
          Text(
            title,
            style: bold16Primary,
          ),
          Text(
            detail,
            style: bold16BlackText,
          ),
        ],
      ),
    );
  }

  burnColories() {
    return Container(
      color: f0Color,
      width: double.maxFinite,
      padding: const EdgeInsets.all(fixPadding * 1.5),
      child: Text(
        "${getTranslation(context, 'confirm.calorie_burned')} : 110 Kcal",
        style: bold16Green,
        textAlign: TextAlign.center,
      ),
    );
  }

  scooterDetail(BuildContext context, Size size) {
    return Padding(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back),
                ),
                heightSpace,
                Text(
                  getTranslation(context, 'confirm.ride_ended'),
                  overflow: TextOverflow.ellipsis,
                  style: bold18BlackText,
                ),
                const Text(
                  "City rider BK2252",
                  style: bold14Primary,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
          widthSpace,
          Image.asset(
            "assets/confirm/image.png",
            width: size.width * 0.35,
            fit: BoxFit.cover,
          )
        ],
      ),
    );
  }
}
