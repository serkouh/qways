import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qways/constant/apiservice.dart';
import 'package:qways/theme/theme.dart';
import 'package:line_icons/line_icons.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final res = await ApiService.post(
        endpoint: "get_geo_quiz_history",
        withAuth: true,
        body: {"limit": 20, "offset": 0},
      );

      final decoded = ApiService.decodeResponse(res);
      if (res.statusCode == 200 && decoded["error"] == false) {
        if (decoded["data"] != null && decoded["data"] is List) {
          setState(() {
            _history = decoded["data"];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      print("Error fetching quiz history: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: f4Color,
      appBar: AppBar(
        title: const Text("Quiz History", style: bold18BlackText),
        backgroundColor: f4Color,
        foregroundColor: black2FColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _hasError
              ? _buildErrorView()
              : _history.isEmpty
                  ? _buildEmptyView()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: fixPadding * 1.5, vertical: fixPadding),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryCard(_history[index]);
                      },
                    ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 50),
          heightSpace,
          const Text("Could not load history", style: semibold16BlackText),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LineIcons.history, color: greyColor, size: 60),
          heightSpace,
          Text("No quizzes played yet", style: bold16Grey),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic quiz) {
    final title = quiz["quiz_title"] ?? "Unknown Quiz";
    final score = quiz["score"] ?? 0;
    final accuracy = quiz["quiz_accuracy"] ?? 0;
    final distance = quiz["total_distance_km"] ?? 0.0;
    final date = quiz["created_at"] != null
        ? quiz["created_at"].substring(0, 10)
        : "Unknown Date";

    return Container(
      margin: const EdgeInsets.only(bottom: fixPadding * 1.5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(fixPadding * 1.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LineIcons.trophy, color: primaryColor, size: 28),
                ),
                widthSpace,
                widthSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: bold16BlackText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(date, style: medium14Grey),
                    ],
                  ),
                ),
                Text("$score pts", style: bold18Primary),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 1.5, vertical: fixPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniStat(Icons.speed, "$accuracy%", "Accuracy"),
                _buildMiniStat(Icons.map, "$distance km", "Distance"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: greyColor),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: semibold14BlackText),
            Text(label, style: const TextStyle(fontSize: 10, color: greyColor)),
          ],
        )
      ],
    );
  }
}
