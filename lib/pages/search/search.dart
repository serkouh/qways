import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final recentSearchList = [
    "Mumbai, Maharashtra",
    "Andheri, Kurla road",
    "Bandra, West",
    "Bandra, Kurla complex",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: black2FColor,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        shadowColor: shadowColor.withOpacity(0.3),
        title: TextField(
          cursorColor: primaryColor,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: getTranslation(context, 'search.type_search'),
            hintStyle: bold16Grey,
          ),
        ),
      ),
      body: Column(
        children: [
          useCurrentLocation(),
          recentSearchTitle(),
          recentSearchListContent(),
        ],
      ),
    );
  }

  recentSearchListContent() {
    return Expanded(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: recentSearchList.length,
        padding: const EdgeInsets.only(
            left: fixPadding * 2.0,
            right: fixPadding * 2.0,
            bottom: fixPadding * 1.3,
            top: fixPadding * 1.3),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                const Icon(
                  Icons.history,
                  color: greyColor,
                  size: 20,
                ),
                widthSpace,
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/searchResult');
                    },
                    child: Text(
                      recentSearchList[index],
                      style: bold14Grey,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  recentSearchTitle() {
    return Container(
      width: double.maxFinite,
      color: f0Color,
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 2.0, vertical: fixPadding * 1.8),
      child: Text(
        getTranslation(context, 'search.recently_searched'),
        style: bold14BlackText,
      ),
    );
  }

  useCurrentLocation() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 2.0, vertical: fixPadding * 1.2),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.my_location_rounded,
            color: primaryColor,
          ),
          widthSpace,
          Expanded(
            child: Text(
              getTranslation(context, 'search.use_current_location'),
              style: bold16Primary,
            ),
          )
        ],
      ),
    );
  }
}
