import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';

class FAQsScreen extends StatefulWidget {
  const FAQsScreen({super.key});

  @override
  State<FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  final faqsList = [
    {
      "question": "How to book a ride?",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas amet ut eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra, amet erat feugiat duis.Maecenas amet ut eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra, amet erat feugiat duis.eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra,",
    },
    {
      "question": "How to book a ride?",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas amet ut eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra, amet erat feugiat duis.Maecenas amet ut eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra, amet erat feugiat duis.eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra,",
    },
    {
      "question": "How to book a ride?",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas amet ut eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra, amet erat feugiat duis.Maecenas amet ut eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra, amet erat feugiat duis.eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra,",
    },
    {
      "question": "How to book a ride?",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas amet ut eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra, amet erat feugiat duis.Maecenas amet ut eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra, amet erat feugiat duis.eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra,",
    },
    {
      "question": "How to book a ride?",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas amet ut eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra, amet erat feugiat duis.Maecenas amet ut eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra, amet erat feugiat duis.eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra,",
    },
    {
      "question": "How to book a ride?",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas amet ut eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra, amet erat feugiat duis.Maecenas amet ut eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra, amet erat feugiat duis.eget eu nibh lorem velit. Id ornare lectus mauris, mauris. Pharetra,",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: whiteColor,
        foregroundColor: black2FColor,
        title: Text(
          getTranslation(context, 'faqs.faqs'),
          style: bold18BlackText,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: faqsListContent(),
    );
  }

  faqsListContent() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      itemCount: faqsList.length,
      itemBuilder: (context, index) {
        return Container(
          width: double.maxFinite,
          margin: const EdgeInsets.symmetric(vertical: fixPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              expansionTileTheme: const ExpansionTileThemeData(
                collapsedShape: RoundedRectangleBorder(side: BorderSide.none),
              ),
            ),
            child: ExpansionTile(
              iconColor: black23Color,
              collapsedIconColor: black23Color,
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
              title: Text(
                faqsList[index]['question'].toString(),
                style: semibold16BlackText,
              ),
              childrenPadding: const EdgeInsets.only(
                  left: fixPadding * 2.0,
                  right: fixPadding * 2.0,
                  bottom: fixPadding * 2.0),
              children: [
                Text(
                  faqsList[index]['answer'].toString(),
                  style: regular14Grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
