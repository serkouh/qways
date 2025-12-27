import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';

class SecurityDeposit extends StatefulWidget {
  const SecurityDeposit({super.key});

  @override
  State<SecurityDeposit> createState() => _SecurityDepositState();
}

class _SecurityDepositState extends State<SecurityDeposit> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: whiteColor,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: black2FColor),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          physics: const BouncingScrollPhysics(),
          children: [
            heightBox(size.height * 0.2),
            amount(),
            heightSpace,
            height5Space,
            depositeTitle(),
            height5Space,
            contentText(),
            heightSpace,
            heightSpace,
            heightSpace,
            height5Space,
            payNowButton(),
            laterButton(),
          ],
        ),
      ),
    );
  }

  laterButton() {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: Text(
          getTranslation(context, 'security_deposite.later'),
          style: bold16Primary,
        ),
      ),
    );
  }

  amount() {
    return const Text(
      "\$50",
      style: bold40Primary,
      textAlign: TextAlign.center,
    );
  }

  depositeTitle() {
    return Text(
      getTranslation(context, 'security_deposite.security_deposit'),
      style: bold20BlackText,
      textAlign: TextAlign.center,
    );
  }

  contentText() {
    return Text(
      getTranslation(context, 'security_deposite.content_text'),
      style: semibold15Grey,
      textAlign: TextAlign.center,
    );
  }

  payNowButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/creditcard', arguments: {"id": 0});
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
          getTranslation(context, 'security_deposite.pay_now'),
          style: bold18White,
        ),
      ),
    );
  }
}
