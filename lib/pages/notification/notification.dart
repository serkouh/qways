import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final notificationList = [
    {
      "title": "Quiz Completed",
      "description": "You scored 85% in ‘General Knowledge Challenge’.",
      "time": "2 min",
      "type": "QuizEnd"
    },
    {
      "title": "New Quiz Available",
      "description":
          "Try the new ‘Science & Space’ quiz and earn bonus points!",
      "time": "5 min",
      "type": "NewQuiz"
    },
    {
      "title": "Reward Earned",
      "description": "You earned 100 coins for completing today’s challenge!",
      "time": "10 min",
      "type": "Reward"
    },
    {
      "title": "Level Up!",
      "description": "Congratulations! You reached Level 3 – keep learning!",
      "time": "12 min",
      "type": "LevelUp"
    },
    {
      "title": "Friend Joined",
      "description": "Your friend Alex just joined using your referral link.",
      "time": "15 min",
      "type": "Referral"
    },
    {
      "title": "Daily Bonus",
      "description": "Your daily login bonus of 50 coins has been added.",
      "time": "20 min",
      "type": "Bonus"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Notifications",
          style: bold20BlackText,
        ),
      ),
      body: notificationList.isEmpty
          ? emptyNotificationContent()
          : notificationListContent(),
    );
  }

  emptyNotificationContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE9E9E9),
            ),
            child: const Icon(
              LineIcons.bellSlash,
              size: 28,
              color: greyColor,
            ),
          ),
          heightSpace,
          Text(
            getTranslation(context, 'notification.no_notification'),
            style: bold18Grey,
          ),
          heightSpace,
          heightSpace,
          heightSpace,
        ],
      ),
    );
  }

  notificationListContent() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: fixPadding * 9.0),
      physics: const BouncingScrollPhysics(),
      itemCount: notificationList.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) {
            setState(() {
              notificationList.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
                backgroundColor: blackColor,
                content: Text(
                  getTranslation(context, 'notification.removed_notification'),
                  style: semibold16White,
                ),
              ),
            );
          },
          background: Container(
            color: redColor,
            margin: const EdgeInsets.symmetric(vertical: fixPadding),
          ),
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(fixPadding),
            margin: const EdgeInsets.symmetric(
                vertical: fixPadding, horizontal: fixPadding * 2.0),
            decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.25),
                    blurRadius: 6,
                  )
                ]),
            child: Row(
              children: [
                iconBox(
                  _getIconColor(notificationList[index]['type']),
                  _getIconData(notificationList[index]['type']),
                ),
                widthSpace,
                widthSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notificationList[index]['title'].toString(),
                        style: bold16BlackText,
                      ),
                      heightBox(3),
                      Text(
                        notificationList[index]['description'].toString(),
                        style: bold15Grey,
                      ),
                      heightBox(3),
                      Text(
                        "${notificationList[index]['time']} ${getTranslation(context, 'notification.ago')}",
                        style: semibold14Grey,
                      ),
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

  IconData _getIconData(String? type) {
    switch (type) {
      case "QuizEnd":
        return Icons.check_circle_outline;
      case "NewQuiz":
        return Icons.quiz_outlined;
      case "Reward":
        return Icons.card_giftcard;
      case "LevelUp":
        return Icons.trending_up;
      case "Referral":
        return Icons.person_add_alt_1;
      case "Bonus":
        return Icons.monetization_on_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case "QuizEnd":
        return greenColor;
      case "NewQuiz":
        return primaryColor;
      case "Reward":
        return orangeColor;
      case "LevelUp":
        return blueColor;
      case "Referral":
        return purpleColor;
      case "Bonus":
        return redColor;
      default:
        return greyColor;
    }
  }

  iconBox(Color color, IconData icon) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Icon(
        icon,
        color: whiteColor,
        size: 28,
      ),
    );
  }
}
