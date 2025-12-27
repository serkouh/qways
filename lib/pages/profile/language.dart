import 'package:qways/theme/theme.dart';
import 'package:qways/widget/column_builder.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/localization_const.dart';
import '../../main.dart';

int? languageValue;

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  SharedPreferences? prefs;
  final key = "value";

  @override
  void initState() {
    super.initState();
    _read();
  }

  _read() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      languageValue = prefs!.getInt(key) ?? 0;
    });
  }

  void _changeLanguges(String languageCode) async {
    Locale temp = await setLocale(languageCode);

    // ignore: use_build_context_synchronously
    MyApp.setLocale(context, temp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        foregroundColor: black2FColor,
        titleSpacing: 0,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          getTranslation(context, 'language.language'),
          style: bold18BlackText,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        physics: const BouncingScrollPhysics(),
        children: [
          languageListContent(),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          updateButton(),
        ],
      ),
    );
  }

  updateButton() {
    return InkWell(
      onTap: () {
        setState(() {
          for (int i = 0; i < Languages.languageList.length; i++) {
            if (languageValue == i) {
              _changeLanguges(
                  Languages.languageList[i].languageCode.toString());
            }
          }
        });
        prefs?.setInt(key, languageValue!);
        Navigator.pop(context);
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
            vertical: fixPadding * 1.3, horizontal: fixPadding * 2.0),
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
          getTranslation(context, 'language.update'),
          style: bold18White,
        ),
      ),
    );
  }

  languageListContent() {
    return ColumnBuilder(
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              languageValue = index;
            });
          },
          child: Container(
            width: double.maxFinite,
            margin: const EdgeInsets.symmetric(vertical: fixPadding),
            padding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2.0, vertical: fixPadding * 1.3),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.25),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    Languages.languageList[index].name.toString(),
                    style: semibold16BlackText,
                  ),
                ),
                Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: whiteColor,
                    border: languageValue == index
                        ? Border.all(
                            color: primaryColor,
                            width: 8,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.25),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: Languages.languageList.length,
    );
  }
}

class Languages {
  String? name;
  String? languageCode;
  int? id;

  Languages({this.id, this.languageCode, this.name});

  static final languageList = [
    Languages(id: 0, name: "English", languageCode: 'en'),
    Languages(id: 1, name: "हिंदी", languageCode: 'hi'),
    Languages(id: 2, name: "Indonesian", languageCode: 'id'),
    Languages(id: 3, name: "中国人", languageCode: 'zh'),
    Languages(id: 4, name: "عربي", languageCode: 'ar'),
  ];
}
