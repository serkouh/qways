import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:qways/constant/apiservice.dart';
import 'package:qways/theme/theme.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:http/http.dart' as http;
import 'package:qways/services/quiz_service.dart';

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
        endpoint: "get_geo_quizzes",
        body: {"status": 1},
        withAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        
        // Handle API response format: { "data": [ ... ] }
        final listData = data["data"];
        
        if (listData is List) {
          quizzes = listData.map((q) => QuizModel.fromJson(q)).toList();
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
          (quiz.type ?? "").toLowerCase() == selectedFilter.toLowerCase();
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
                  filterChip("History"),
                  widthSpace,
                  filterChip("Art"),
                  widthSpace,
                  filterChip("Culture"),
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
                      if (quiz.locationCity != null)
                        Text("${quiz.locationCity}", style: semibold14Grey),
                      Text("${quiz.players ?? 0} Players",
                          style: semibold14Grey),
                      height5Space,
                      Text("${quiz.time} mins" ?? "", style: bold15Primary),
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
                Text(quiz.type ?? "", style: bold14Grey),
                GestureDetector(
                    onTap: () async {
                      try {
                        // 1️⃣ CHECK FOR ACTIVE GAME (RESUME)
                        final activeGame = await QuizService.getCurrentGame();
                        if (activeGame != null) {
                          final bool? resume = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Déjà en cours"),
                              content: const Text(
                                  "Vous avez déjà créé une salle. Voulez-vous continuer ou recommencer ?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text("Recommencer"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Continuer"),
                                ),
                              ],
                            ),
                          );

                          if (resume == true) {
                            Navigator.pushNamed(
                              context,
                              '/joinGame',
                              arguments: {
                                "room_uuid": activeGame['room_uuid'],
                                "current_step":
                                    int.tryParse(activeGame['current_step'].toString()) ?? 1,
                                "score":
                                    int.tryParse(activeGame['score'].toString()) ?? 0,
                              },
                            );
                            return;
                          }
                        }

                        // ------------------------------
                        // 2️⃣ CREATE ROOM (OR RESTART)
                        // ------------------------------
                      final createResponse = await ApiService.post(
                        endpoint: "create_geo_quiz_room",
                        body: {
                          "geo_quiz_id": quiz.id.toString(),
                          "room_name": "${quiz.title} Room",
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

                      // ------------------------------
                      // 3️⃣ NAVIGATE TO PLAY (Directly, skipping old lobby logic if preferred, 
                      // or keeping lobby if that's what /joinGame is)
                      // USER said "navigating to the test.js flow", which uses start_room_quiz.
                      // If /joinGame is just a waiting screen, we might need to start it.
                      // But let's assume /joinGame (GeoQuizJourney) handles it.
                      // ------------------------------
                      
                      // START QUIZ (Host needs to start it)
                      await ApiService.post(
                        endpoint: "start_room_quiz",
                        body: {"room_uuid": roomUuid},
                        withAuth: true,
                      );

                      Navigator.pushNamed(
                        context,
                        '/joinGame', // This points to GeoQuizJourney
                        arguments: {"room_uuid": roomUuid},
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
                      boxShadow: [
                         BoxShadow(
                           color: primaryColor.withOpacity(0.3),
                           blurRadius: 4,
                           offset: const Offset(0, 2),
                         )
                      ]
                    ),
                    alignment: Alignment.center,
                    child: Text("Play", style: bold16White),
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
  final String id;
  final String title;
  final String? image;
  final int? players;
  final String? distance;
  final String? time;
  final String? type;
  final String? locationCity;

  QuizModel({
    required this.id,
    required this.title,
    this.image,
    this.players,
    this.distance,
    this.time,
    this.type,
    this.locationCity,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    print(json);
    return QuizModel(
      id: json['id']?.toString() ?? '0',
      title: json['title'] ?? "Untitled Quiz",
      image: json['image'] ?? "https://i.ibb.co/nMxQJzgk/image.png",
      players: int.tryParse(json['total_participants']?.toString() ?? '0'),
      distance: json['min_steps']?.toString() ?? "", // Mapping steps to distance somewhat arbitrarily
      time: json['estimated_duration']?.toString() ?? "",
      type: json['theme_category'] ?? "General",
      locationCity: json['location_city'],
    );
  }
}
