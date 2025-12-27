import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';

class WalletSuccessScreen extends StatefulWidget {
  const WalletSuccessScreen({super.key});

  @override
  State<WalletSuccessScreen> createState() => _WalletSuccessScreenState();
}

class _WalletSuccessScreenState extends State<WalletSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Column(
              children: [
                doneLogo(size),
                heightSpace,
                heightSpace,
                amountText(),
                height5Space,
                congratulationText(),
                heightSpace,
                heightSpace,
                heightSpace,
                heightSpace,
                backHomeButton()
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: contactUsText(),
    );
  }

  backHomeButton() {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(horizontal: fixPadding * 5.0),
      child: OutlinedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          side: MaterialStateProperty.all(
            const BorderSide(
              color: whiteColor,
            ),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.all(fixPadding * 1.4),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/bottombar');
        },
        child: Text(
          getTranslation(context, 'wallet_success.back_home'),
          style: bold16White,
        ),
      ),
    );
  }

  congratulationText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 6.0),
      child: Text(
        getTranslation(context, 'wallet_success.congratulation'),
        style: medium14White,
        textAlign: TextAlign.center,
      ),
    );
  }

  amountText() =>
      Text("\$100 ${getTranslation(context, 'wallet_success.added')}",
          style: bold25White);

  doneLogo(Size size) {
    return Container(
      padding: const EdgeInsets.all(fixPadding),
      height: size.height * 0.17,
      width: size.height * 0.17,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF9CD4F1),
        border: Border.all(color: const Color(0xFFCEEEFF), width: 15),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.done,
          color: whiteColor,
          size: 40,
        ),
      ),
    );
  }

  contactUsText() {
    return Padding(
      padding: const EdgeInsets.all(fixPadding),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/help');
        },
        child: Text(
          getTranslation(context, 'wallet_success.contact_us'),
          style: semibold16White.copyWith(
            color: const Color(0xFFEDE8E8),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
