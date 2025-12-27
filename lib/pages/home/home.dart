import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:qways/constant/apiservice.dart';
import 'package:qways/theme/theme.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:http/http.dart' as http;

class QuizDashboard extends StatefulWidget {
  const QuizDashboard({super.key});

  @override
  State<QuizDashboard> createState() => _QuizDashboardState();
}

class _QuizDashboardState extends State<QuizDashboard> {
  List<QuizModel> quizzes = [];
  bool isLoading = true;
  String selectedFilter = "All";
  String searchText = "";

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    setState(() => isLoading = true);

    try {
      // API expects POST with JSON body: { "status": 1 }
      final response = await ApiService.post(
        endpoint: "get_all_live_rooms",
        body: {"include_private": 0, "limit": 10},
        withAuth: true, // if your ApiService supports adding token
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        // The API returns data inside "data" field, based on your test.js
        if (data["data"]["rooms"] is List) {
          quizzes = (data["data"]["rooms"] as List)
              .map((q) => QuizModel.fromJson(q))
              .toList();
        } else if (data is List) {
          quizzes = data.map((q) => QuizModel.fromJson(q)).toList();
        }

        print("✅ Loaded ${quizzes.length} quizzes");
      } else {
        print("❌ Failed to load quizzes: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("⚠️ Error fetching quizzes: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuizzes = quizzes.where((quiz) {
      final matchesFilter = selectedFilter == "All" ||
          quiz.type!.toLowerCase() == selectedFilter.toLowerCase();
      final matchesSearch =
          quiz.title.toLowerCase().contains(searchText.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        title: Text(
          getTranslation(context, "Available Quizzes"),
          style: bold16BlackText,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(fixPadding * 2),
        child: Column(
          children: [
            // 🔍 Search Bar
            Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: fixPadding),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(color: blackColor.withOpacity(0.1), blurRadius: 4)
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: primaryColor),
                  widthSpace,
                  Expanded(
                    child: TextField(
                      onChanged: (value) => setState(() => searchText = value),
                      decoration: const InputDecoration(
                        hintText: "Search quiz...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            heightSpace,

            // 🏷️ Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  filterChip("All"),
                  widthSpace,
                  filterChip("Nearby"),
                  widthSpace,
                  filterChip("Open"),
                  widthSpace,
                  filterChip("With Friends"),
                ],
              ),
            ),

            heightSpace,

            // 🧠 Quizzes List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredQuizzes.isEmpty
                      ? const Center(child: Text("No quizzes available"))
                      : RefreshIndicator(
                          onRefresh: fetchQuizzes,
                          child: ListView.builder(
                            itemCount: filteredQuizzes.length,
                            itemBuilder: (context, index) {
                              final quiz = filteredQuizzes[index];
                              return gameCard(quiz);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterChip(String text) {
    final isSelected = selectedFilter == text;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.2)
              : primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
          ),
        ),
        child: Text(text, style: isSelected ? bold14Primary : semibold14Grey),
      ),
    );
  }

  Widget gameCard(QuizModel quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: fixPadding * 1.5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(color: blackColor.withOpacity(0.1), blurRadius: 4)
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(fixPadding * 1.5),
            child: Row(
              children: [
                Image.network(
                  quiz.image ?? "https://via.placeholder.com/150",
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                      "assets/auth/image.png",
                      width: 90,
                      height: 90),
                ),
                widthSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quiz.title, style: bold15BlackText),
                      height5Space,
                      Text("${quiz.players ?? 0} Players",
                          style: semibold14Grey),
                      height5Space,
                      Text(quiz.time ?? "", style: bold15Primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          DottedBorder(
            dashPattern: const [3],
            color: greyColor,
            child: Container(width: double.maxFinite),
          ),
          Padding(
            padding: const EdgeInsets.all(fixPadding * 1.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(quiz.distance ?? "", style: bold14Grey),
                GestureDetector(
                  onTap: () async {
                    try {
                      // ------------------------------
                      // 1️⃣ CREATE ROOM
                      // ------------------------------
                      final createResponse = await ApiService.post(
                        endpoint: "create_geo_quiz_room",
                        body: {
                          "geo_quiz_id": quiz.id.toString(),
                          "room_name": "Paris Challenge Room",
                          "max_participants": 5,
                          "room_type": "public",
                        },
                        withAuth: true,
                      );

                      print("🔽 CreateRoom response: ${createResponse.body}");

                      if (createResponse.statusCode != 200) {
                        print(getApiMessage(createResponse.body));
                        return;
                      }

                      final createData = jsonDecode(createResponse.body);

                      if (createData["data"] == null) {
                        print(getApiMessage(createResponse.body));
                        return;
                      }

                      final roomUuid = createData["data"]["room_uuid"];
                      print("🏠 Room created: $roomUuid");

                      // ------------------------------
                      // 2️⃣ JOIN ROOM
                      // ------------------------------
                      final joinResponse = await ApiService.post(
                        endpoint: "join_geo_quiz_room",
                        body: {"room_uuid": roomUuid},
                        withAuth: true,
                      );

                      print("🔽 JoinRoom response: ${joinResponse.body}");

                      if (joinResponse.statusCode != 200 ||
                          joinResponse.body.isEmpty ||
                          joinResponse.body == "{}") {
                        print(getApiMessage(joinResponse.body));
                        return;
                      }

                      final joinData = jsonDecode(joinResponse.body);

                      if (joinData["data"] == null) {
                        print(getApiMessage(joinResponse.body));
                        return;
                      }

                      print("🎮 Successfully joined room: $roomUuid");

                      // ------------------------------
                      // 3️⃣ NAVIGATE TO LOBBY
                      // ------------------------------
                      Navigator.pushNamed(
                        context,
                        '/joinGame',
                        arguments: {"room_uuid": quiz.id},
                      );
                    } catch (e) {
                      print("⚠️ Error creating/joining room: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Something went wrong. Try again.")),
                      );
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    alignment: Alignment.center,
                    child: Text("Join", style: bold16White),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class QuizModel {
  final String id; // 👈 NEW
  final String title;
  final String? image;
  final int? players;
  final String? distance;
  final String? time;
  final String? type;

  QuizModel({
    required this.id, // 👈 NEW
    required this.title,
    this.image,
    this.players,
    this.distance,
    this.time,
    this.type,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    print(json);
    return QuizModel(
      id: json['geo_quiz_id']?.toString() ?? '0', // 👈 NEW
      title: json['title'] ?? "Untitled Quiz",
      image: json['image'] ?? "assets/auth/image.png",
      players: json['players'] ?? 0,
      distance: json['distance'] ?? "",
      time: json['time'] ?? "",
      type: json['type'] ?? "",
    );
  }
}
