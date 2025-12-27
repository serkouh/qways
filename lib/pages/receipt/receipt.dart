import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: f4Color,
        appBar: AppBar(
          backgroundColor: whiteColor,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
          ),
          elevation: 0,
          foregroundColor: black2FColor,
          centerTitle: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            topDetail(size, context),
            receiptDetails(context),
          ],
        ),
        bottomNavigationBar: contactUsText(context),
      ),
    );
  }

  receiptDetails(context) {
    return Padding(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Column(
        children: [
          receiptDetailWidget(
              getTranslation(context, 'receipt.ride_start_location'),
              CupertinoIcons.placemark,
              "1901, Thornridge Cir, Mumbai ,Maharashtra",
              getTranslation(context, 'receipt.ride_end_location'),
              CupertinoIcons.placemark,
              "1901, Thornridge Cir, Mumbai ,Maharashtra"),
          heightSpace,
          heightSpace,
          receiptDetailWidget(
              getTranslation(context, 'receipt.purpose'),
              Icons.directions_bike,
              "Ride of cycle",
              getTranslation(context, 'receipt.payment_method'),
              Icons.credit_card,
              "Credit card"),
          heightSpace,
          heightSpace,
          receiptDetailWidget(
              getTranslation(context, 'receipt.payment_date'),
              Icons.calendar_today_outlined,
              "20 April 2020",
              getTranslation(context, 'receipt.payment_time'),
              Icons.access_time,
              "Monday 11:PM"),
          heightSpace,
          heightSpace,
          receiptDetailWidget(
              getTranslation(context, 'receipt.cycle_no'),
              Icons.directions_bike,
              "BK4567",
              getTranslation(context, 'receipt.receipt_no'),
              Icons.list_alt_outlined,
              "1245611"),
          heightSpace,
          heightSpace,
          receiptDetailWidget(
              getTranslation(context, 'receipt.name'),
              Icons.person_outline,
              "Jeklin shah",
              getTranslation(context, 'receipt.ride_time'),
              Icons.access_time,
              "2 Hour"),
        ],
      ),
    );
  }

  receiptDetailWidget(title, icon, detail, title2, icon2, detail2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: bold15BlackText,
                overflow: TextOverflow.ellipsis,
              ),
              height5Space,
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: greyColor,
                  ),
                  width5Space,
                  Expanded(
                    child: Text(
                      detail,
                      style: bold12Grey,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        widthSpace,
        widthSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title2,
                style: bold15BlackText,
                overflow: TextOverflow.ellipsis,
              ),
              height5Space,
              Row(
                children: [
                  Icon(
                    icon2,
                    size: 20,
                    color: greyColor,
                  ),
                  width5Space,
                  Expanded(
                    child: Text(
                      detail2,
                      style: bold12Grey,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  contactUsText(context) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: fixPadding * 2.0,
          top: fixPadding,
          left: fixPadding * 2.0,
          right: fixPadding * 2.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/help');
        },
        child: Text.rich(
          TextSpan(
            text: getTranslation(context, 'receipt.need_more_help'),
            style: bold15Grey,
            children: [
              const TextSpan(text: " "),
              TextSpan(
                  text: getTranslation(context, 'receipt.contact_us'),
                  style: bold15Primary)
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  topDetail(Size size, context) {
    return Container(
      padding: const EdgeInsets.only(bottom: fixPadding * 3.5, top: fixPadding),
      width: double.maxFinite,
      color: whiteColor,
      child: Column(
        children: [
          Container(
            height: size.height * 0.14,
            width: size.height * 0.14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Icon(
              Icons.directions_bike,
              color: primaryColor,
              size: size.height * 0.07,
            ),
          ),
          heightSpace,
          height5Space,
          Text(
            getTranslation(context, 'receipt.you_paid'),
            style: bold18BlackText,
          ),
          const Text(
            "\$12.00",
            style: bold22Primary,
          )
        ],
      ),
    );
  }
}
