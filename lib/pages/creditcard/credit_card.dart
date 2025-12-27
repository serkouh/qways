import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class CreditCardScreen extends StatefulWidget {
  const CreditCardScreen({super.key});

  @override
  State<CreditCardScreen> createState() => _CreditCardScreenState();
}

class _CreditCardScreenState extends State<CreditCardScreen> {
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    var id = data['id'];
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: whiteColor,
          centerTitle: false,
          titleSpacing: 0,
          elevation: 0,
          leading: IconButton(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: black2FColor,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: fixPadding * 2),
          physics: const BouncingScrollPhysics(),
          children: [
            creditCard(size),
            heightSpace,
            heightSpace,
            enterDetailTitle(),
            creditCardFields(),
            heightSpace,
            heightSpace,
            heightSpace,
            height5Space,
            payNowButton(id),
          ],
        ),
      ),
    );
  }

  payNowButton(id) {
    return InkWell(
      onTap: () {
        id == 0
            ? Navigator.pushNamed(context, '/success')
            : Navigator.pushNamed(context, '/walletSuccess');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
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

  enterDetailTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Text(
        getTranslation(context, 'credit_card.enter_details'),
        style: semibold16BlackText,
      ),
    );
  }

  creditCard(Size size) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CreditCardWidget(
          padding: 0,
          height: size.height * 0.3,
          bankName: getTranslation(context, 'credit_card.credit_card'),
          backgroundImage: "assets/creditcard/CreditcardBg.png",
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardType: CardType.mastercard,
          cardHolderName: cardHolderName,
          cvvCode: cvvCode,
          showBackView: isCvvFocused,
          isHolderNameVisible: true,
          cardBgColor: whiteColor,
          isChipVisible: false,
          obscureCardCvv: true,
          obscureCardNumber: true,
          customCardTypeIcons: [
            CustomCardTypeIcon(
              cardType: CardType.mastercard,
              cardImage: Image.asset(
                "assets/creditcard/Mastercard-Logo.png",
                fit: BoxFit.contain,
                height: 30,
                width: 50,
              ),
            ),
          ],
          onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
        ),
      ),
    );
  }

  Widget creditCardFields() {
    return CreditCardForm(
      cardHolderName: "serkouh",
      cardNumber: "424242424242424242",
      cvvCode: "677",
      expiryDate: "7/26",
      formKey: formKey,
      obscureCvv: true,
      onCreditCardModelChange: (CreditCardModel creditCardModel) {
        setState(() {
          cardNumber = creditCardModel.cardNumber;
          expiryDate = creditCardModel.expiryDate;
          cardHolderName = creditCardModel.cardHolderName;
          cvvCode = creditCardModel.cvvCode;
          isCvvFocused = creditCardModel.isCvvFocused;
        });
      },
    );
  }

  InputDecoration _inputDecoration(BuildContext context,
      {required String label, required String hint}) {
    return InputDecoration(
      border: InputBorder.none,
      labelText: label,
      hintText: hint,
      labelStyle: semibold18Grey,
      hintStyle: semibold16Grey,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: greyB4Color),
        borderRadius: BorderRadius.circular(5.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: primaryColor),
        borderRadius: BorderRadius.circular(5.0),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      alignLabelWithHint: true,
    );
  }
}
