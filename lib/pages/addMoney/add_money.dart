import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';

class AddMoneyScreen extends StatelessWidget {
  const AddMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        foregroundColor: black2FColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: black2FColor,
          ),
        ),
        titleSpacing: 0,
        title: Text(
          getTranslation(context, 'add_money.add_money'),
          style: bold18BlackText,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        children: [
          heightSpace,
          enterAmountTitle(context),
          heightSpace,
          amountField(context),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          addButton(context),
        ],
      ),
    );
  }

  addButton(context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/creditcard', arguments: {"id": 1});
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
          getTranslation(context, 'add_money.add'),
          style: bold18White,
        ),
      ),
    );
  }

  enterAmountTitle(context) {
    return Text(
      getTranslation(context, 'add_money.enter_amount'),
      style: bold16Grey,
    );
  }

  amountField(context) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.25),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextField(
        style: bold18Primary,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: fixPadding * 1.5),
          hintText: getTranslation(context, 'add_money.amount'),
          hintStyle: semibold16Grey,
          prefixText: "\$",
          prefixStyle: bold18Primary,
        ),
      ),
    );
  }
}
