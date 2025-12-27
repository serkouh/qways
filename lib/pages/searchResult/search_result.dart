import 'package:dotted_border/dotted_border.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/pages/profile/language.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({super.key});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final stationList = [
    {
      "image": "assets/home/cycle1.png",
      "address": "6391 Elgin St. Celina, Mumbai ,Maharashtra",
      "time": "15 min",
      "distance": "2.5 km",
      "available": 5,
      "battery": "90%",
      "range": "30-35 km",
    },
    {
      "image": "assets/home/cycle3.png",
      "address": "8502 Preston Road, Mumbai ,Maharashtra",
      "time": "25 min",
      "distance": "3.5 km",
      "available": 4,
      "battery": "90%",
      "range": "30-35 km",
    },
    {
      "image": "assets/home/cycle2.png",
      "address": "4140, Parker road,Mumbai ,Maharashtra",
      "time": "30 min",
      "distance": "4.5 km",
      "available": 10,
      "battery": "90%",
      "range": "30-35 km",
    },
    {
      "image": "assets/home/cycle1.png",
      "address": "1901, Thornridge Cir, Mumbai ,Maharashtra",
      "time": "30 min",
      "distance": "4.5 km",
      "available": 8,
      "battery": "90%",
      "range": "30-35 km",
    },
    {
      "image": "assets/home/cycle2.png",
      "address": "6391 Elgin St. Celina, Mumbai ,Maharashtra",
      "time": "15 min",
      "distance": "2.5 km",
      "available": 5,
      "battery": "90%",
      "range": "30-35 km",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        centerTitle: false,
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: whiteColor,
        foregroundColor: black2FColor,
        leading: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "City rider",
              style: bold16BlackText,
            ),
            heightBox(2),
            const Text(
              "Mumbai, Maharashtra",
              style: bold14Grey,
            )
          ],
        ),
      ),
      body: stationListContent(size),
    );
  }

  stationListContent(Size size) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: fixPadding),
      physics: const BouncingScrollPhysics(),
      itemCount: stationList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/detail');
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2, vertical: fixPadding),
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
            width: double.maxFinite,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: fixPadding, horizontal: fixPadding * 1.5),
                  child: Row(
                    children: [
                      Image.asset(
                        stationList[index]['image'].toString(),
                        width: size.width * 0.4,
                        height: 85,
                      ),
                      widthSpace,
                      stationDetail(index)
                    ],
                  ),
                ),
                height5Space,
                DottedBorder(
                  padding: EdgeInsets.zero,
                  dashPattern: const [3],
                  color: greyColor,
                  child: Container(
                    width: double.maxFinite,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: fixPadding * 1.5, vertical: fixPadding),
                  child: Row(
                    children: [
                      scootersDetail(index),
                      widthSpace,
                      goDetailButton(),
                      widthSpace,
                      locationButton(),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  locationButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/direction');
      },
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: whiteColor,
          boxShadow: [
            BoxShadow(color: blackColor.withOpacity(0.25), blurRadius: 6)
          ],
        ),
        child: const Icon(
          Icons.near_me,
          color: primaryColor,
        ),
      ),
    );
  }

  goDetailButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/detail');
      },
      child: Container(
        height: 40,
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: fixPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: primaryColor,
          boxShadow: [
            BoxShadow(color: blackColor.withOpacity(0.25), blurRadius: 6)
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'search_result.go_detail'),
          style: bold16White,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  scootersDetail(int index) {
    return Expanded(
      child: Row(
        children: [
          Column(
            children: [
              Text(
                getTranslation(context, 'search_result.battery'),
                style: bold14Grey,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                stationList[index]['battery'].toString(),
                style: bold12BlackText,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: fixPadding),
            height: 30,
            width: 1,
            color: greyColor,
          ),
          Expanded(
            child: Align(
              alignment: languageValue == 4
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Column(
                children: [
                  Text(
                    getTranslation(context, 'search_result.range'),
                    style: bold14Grey,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    stationList[index]['range'].toString(),
                    style: bold12BlackText,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  stationDetail(int index) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stationList[index]['address'].toString(),
            style: bold15BlackText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          height5Space,
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: greyColor,
                size: 15,
              ),
              Expanded(
                child: Text(
                    "${stationList[index]['time']}/${stationList[index]['distance']}",
                    style: semibold14Grey,
                    overflow: TextOverflow.ellipsis),
              )
            ],
          ),
          height5Space,
          Text(
            "${stationList[index]['available']} ${getTranslation(context, 'search_result.scooters_available')}",
            style: bold15Primary,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
