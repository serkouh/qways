import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:qways/constant/apiservice.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';

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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz History",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _hasError
              ? const Center(child: Text("Failed to load history"))
              : _history.isEmpty
                  ? const Center(child: Text("No quiz history found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final quiz = _history[index];
                        return _buildQuizCard(quiz, size);
                      },
                    ),
    );
  }

  Widget _buildQuizCard(dynamic quiz, Size size) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Image.asset(
                  "assets/auth/image.png",
                  width: size.width * 0.22,
                  height: 70,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz["quiz_title"] ?? "Unknown Quiz",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Score: ${quiz["score"] ?? 0}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey[300],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Accuracy: ${quiz["quiz_accuracy"] ?? 0}%",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text("Distance: ${quiz["total_distance_km"] ?? 0} km",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              final uuid = quiz["room_uuid"]?.toString();
              if (uuid != null) {
                Navigator.pushNamed(context, '/joinGame',
                    arguments: {"room_uuid": uuid});
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Resume",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
