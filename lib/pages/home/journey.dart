import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qways/theme/theme.dart';
import 'package:qways/constant/apiservice.dart';
import 'package:qways/services/quiz_service.dart';
import 'package:qways/model/quiz_models.dart';

class GeoQuizJourney extends StatefulWidget {
  const GeoQuizJourney({super.key});

  @override
  State<GeoQuizJourney> createState() => _GeoQuizJourneyState();
}

class _GeoQuizJourneyState extends State<GeoQuizJourney> {
  int currentStep = 0;
  bool showQuestion = false;
  bool showCongrats = false;
  bool inRange = false;

  // NEW → QR verification flag
  bool qrVerifiedForThisQuestion = false;

  double rangeRadius = 60; // meters

  GoogleMapController? _mapController;
  Position? userPosition;
  StreamSubscription<Position>? positionStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // The navigator may pass either a geo_quiz_id (numeric) or a room_uuid (string like GQR_...)
    roomUuid = args["room_uuid"]?.toString();

    print("📥 Received navigation arg (room_uuid or geo_quiz_id): $roomUuid");

    if (roomUuid == null) return;

    // If it contains letters/underscore, assume it's a room UUID and load questions from the room
    final isRoomUuid = RegExp(r'[A-Za-z_]').hasMatch(roomUuid!);
    if (isRoomUuid) {
      _loadFromRoom(roomUuid!);
    } else {
      // otherwise treat as geo_quiz_id
      getGeoQuizDetails(roomUuid!);
    }
  }

  GeoQuiz? quiz;
  List<GeoQuizStep> steps = [];

  Future<void> getGeoQuizDetails(String quizId) async {
    print("📡 Calling → get_geo_quiz_details");
    print("📦 Body: {geo_quiz_id: $quizId}");

    final response = await ApiService.post(
      endpoint: "get_geo_quiz_details",
      body: {"geo_quiz_id": quizId},
      withAuth: true,
    );

    print("🔽 API Response:");
    print(response.body);

    final decoded = jsonDecode(response.body);

    final details = GeoQuizDetailsResponse.fromJson(decoded);
    printGeoQuizDetails(details);

    setState(() {
      quiz = details.data;
      steps = quiz!.steps;
    });

    print("🎉 Loaded quiz: ${quiz!.title}");
    print("📍 Total steps: ${steps.length}");

    _setNextStepLocation();
  }

  Future<void> _loadFromRoom(String roomUuid) async {
    try {
      print("📡 Calling → get_room_quiz_questions for room: $roomUuid");
      final questions = await QuizService.getQuestions(roomUuid);
      if (questions.isEmpty) {
        print("⚠️ No questions returned for room: $roomUuid");
        return;
      }

      final converted = questions.map((q) {
        return GeoQuizStep(
          id: q.stepNumber,
          stepNumber: q.stepNumber,
          question: q.question,
          option1: q.option1,
          option2: q.option2,
          option3: q.option3,
          correctAnswer: 0,
          latitude: q.latitude,
          longitude: q.longitude,
          radiusMeters: 60,
          penaltyMinutes: 0,
          hint: '',
          imageUrl: '',
          points: q.points,
          timeLimitSeconds: q.timeLimitSeconds,
        );
      }).toList();

      final wrapper = GeoQuiz(
        id: 0,
        title: 'Room Quiz',
        description: 'Loaded from room',
        locationCity: '',
        locationCountry: '',
        themeCategory: '',
        minSteps: converted.length,
        totalSteps: converted.length,
        estimatedDuration: 0,
        difficultyLevel: '',
        createdBy: 0,
        status: 1,
        isPublished: 1,
        dateCreated: '',
        dateUpdated: null,
        startDate: '',
        endDate: '',
        totalParticipants: 0,
        steps: converted,
      );

      setState(() {
        quiz = wrapper;
        steps = converted;
      });

      _setNextStepLocation();
    } catch (e) {
      print('Error loading room questions: $e');
    }
  }

  void _setNextStepLocation() {
    if (steps.isEmpty || currentStep >= steps.length) return;

    final step = steps[currentStep];

    nextQuestionLocation = LatLng(step.latitude, step.longitude);

    _checkProximity();

    setState(() {});
  }

  LatLng? nextQuestionLocation;
  int score = 0;
  int? selectedAnswer;
  String? roomUuid;
  int penaltyRemainingSeconds = 0;
  Timer? _penaltyTimer;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _generateNextQuestionLocation();

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((position) {
      setState(() {
        userPosition = position;
        _checkProximity();
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }
    });
  }

  void _generateNextQuestionLocation({double? minDistanceMeters}) {
    if (userPosition == null) return;

    final random = Random();
    final double distanceMeters = (minDistanceMeters ?? 20) +
        random.nextDouble() *
            (max(rangeRadius * 1.5, 50) - (minDistanceMeters ?? 20));
    final double bearing = random.nextDouble() * 2 * pi;

    final double deltaLat = (distanceMeters * cos(bearing)) / 111000;
    final double metersPerDegLng =
        111000 * cos(userPosition!.latitude * pi / 180).abs();
    final double deltaLng = metersPerDegLng > 0
        ? (distanceMeters * sin(bearing)) / metersPerDegLng
        : 0.0;

    nextQuestionLocation = LatLng(
      userPosition!.latitude + deltaLat,
      userPosition!.longitude + deltaLng,
    );

    _checkProximity();

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(userPosition!.latitude, userPosition!.longitude),
          16,
        ),
      );
    }

    setState(() {});
  }

  void _checkProximity() {
    if (userPosition == null || nextQuestionLocation == null) {
      setState(() => inRange = false);
      return;
    }

    final double distance = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      nextQuestionLocation!.latitude,
      nextQuestionLocation!.longitude,
    );

    setState(() {
      inRange = distance <= rangeRadius;
    });
  }

  void _startPenaltyTimer(int seconds) {
    _penaltyTimer?.cancel();
    setState(() {
      penaltyRemainingSeconds = seconds;
    });

    _penaltyTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (penaltyRemainingSeconds <= 1) {
        t.cancel();
        setState(() => penaltyRemainingSeconds = 0);
      } else {
        setState(() => penaltyRemainingSeconds -= 1);
      }
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    _mapController?.dispose();
    _penaltyTimer?.cancel();
    super.dispose();
  }

  Future<void> _submitAnswer(GeoQuizStep step, int selectedIndex) async {
    if (roomUuid == null) return;
    if (penaltyRemainingSeconds > 0) return;
    if (submitting) return;

    setState(() => submitting = true);

    try {
      final lat = userPosition?.latitude ?? 0.0;
      final lng = userPosition?.longitude ?? 0.0;

      final res = await ApiService.post(
        endpoint: "submit_room_quiz_answer",
        withAuth: true,
        body: {
          "room_uuid": roomUuid,
          "step_number": step.stepNumber,
          "selected_answer": (selectedIndex + 1).toString(),
          "latitude": lat,
          "longitude": lng,
          "time_taken": step.timeLimitSeconds,
        },
      );

      final decoded = ApiService.decodeResponse(res);
      print("🔽 submit_room_quiz_answer → ${res.body}");

      if (res.statusCode == 200 && decoded["error"] == false) {
        final data = decoded["data"] ?? {};
        final bool isCorrect =
            data["is_correct"] == true || data["is_correct"] == 1;
        final String correctAnswer = (data["correct_answer"] ?? "").toString();

        if (isCorrect) {
          setState(() =>
              score += (int.parse(data["points_earned"].toString()) ?? 0));
        } else {
          final int penalty = (data["time_penalty_seconds"] ?? 0) as int;
          if (penalty > 0) _startPenaltyTimer(penalty);
        }

        final bool completed = data["is_quiz_completed"] == true;
        final int serverCurrentStep =
            (data["current_step"] ?? currentStep + 1) as int;

        if (completed) {
          setState(() => showCongrats = true);
        } else {
          setState(() {
            currentStep = serverCurrentStep - 1; // server uses 1-based
            selectedAnswer = null;
            showQuestion = false;
            qrVerifiedForThisQuestion = false;
          });
          _setNextStepLocation();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isCorrect
                  ? "Correct!"
                  : (data["penalty_message"] ?? "Wrong answer"))),
        );
      } else {
        final message = decoded["message"]?.toString() ?? res.body;
        if (message == "129" || decoded["data"]?['in_penalty'] == true) {
          final int remaining =
              decoded["data"]?["penalty_remaining_seconds"] ?? 0;
          _startPenaltyTimer(remaining);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(decoded["data"]?["message"] ?? "In penalty")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(getApiMessage(decoded) ?? "Error")),
          );
        }
      }
    } catch (e) {
      print("Error submitting answer: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit answer")),
      );
    } finally {
      setState(() => submitting = false);
    }
  }

  // -----------------------------------------
  // ************** UI SCREENS ***************
  // -----------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: showCongrats
          ? _buildCongratsScreen()
          : showQuestion && !qrVerifiedForThisQuestion
              ? _buildQrScanForQuestion()
              : showQuestion && qrVerifiedForThisQuestion
                  ? _buildQuestionScreen()
                  : _buildMapScreen(),
    );
  }

  // ------------------------------------------------
  // 🔳 QR SCREEN — MUST SCAN BEFORE SEEING QUESTION
  // ------------------------------------------------

  Widget _buildQrScanForQuestion() {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 120, color: primaryColor),
            const SizedBox(height: 20),
            const Text(
              "Scan the QR code to unlock the question",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                // TODO: Replace with real QR scan
                print("📷 Simulating QR Scan SUCCESS");
                setState(() {
                  qrVerifiedForThisQuestion = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              ),
              child: const Text(
                "Scan QR",
                style: TextStyle(color: whiteColor),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => setState(() => showQuestion = false),
              child: const Text("Back to map"),
            )
          ],
        ),
      ),
    );
  }

  // ------------------------------------------
  // MAP SCREEN
  // ------------------------------------------

  Widget _buildMapScreen() {
    final LatLng userLatLng = userPosition == null
        ? const LatLng(48.8566, 2.3522)
        : LatLng(userPosition!.latitude, userPosition!.longitude);

    final Set<Marker> markers = {};
    if (nextQuestionLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId("next"),
        position: nextQuestionLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));
    }

    if (userPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId("user"),
        position: userLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }

    final Set<Circle> circles = {
      Circle(
        circleId: const CircleId("range"),
        center: userLatLng,
        radius: rangeRadius,
        fillColor: primaryColor.withOpacity(0.15),
        strokeColor: primaryColor,
        strokeWidth: 2,
      ),
    };

    return Scaffold(
      backgroundColor: whiteColor,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: userLatLng, zoom: 16),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: markers,
            circles: circles,
            zoomControlsEnabled: false,
          ),

          ///
          /// Floating Button: Answer Question
          ///
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  showQuestion = true;
                  qrVerifiedForThisQuestion = false; // RESET
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: (inRange && nextQuestionLocation != null)
                    ? primaryColor
                    : greyColor,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                "Answer Question",
                style:
                    TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------
  // QUESTION SCREEN
  // ------------------------------------------

  Widget _buildQuestionScreen() {
    if (steps.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final step = steps[currentStep];

    final answers = [step.option1, step.option2, step.option3];

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Question ${currentStep + 1}/${steps.length}",
                  style: semibold14Grey),
              const SizedBox(height: 10),
              Text(step.question,
                  textAlign: TextAlign.center, style: bold20BlackText),
              const SizedBox(height: 20),
              if (penaltyRemainingSeconds > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        "Penalty active — wait ${penaltyRemainingSeconds}s",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ...List.generate(answers.length, (i) {
                final isSelected = selectedAnswer == i;
                final disabled = penaltyRemainingSeconds > 0 || submitting;
                return GestureDetector(
                  onTap: disabled
                      ? null
                      : () => setState(() => selectedAnswer = i),
                  child: Opacity(
                    opacity: disabled ? 0.6 : 1.0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor.withOpacity(0.1)
                            : const Color(0xFFF6F6F6),
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        answers[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? primaryColor : blackColor,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (selectedAnswer == null ||
                        penaltyRemainingSeconds > 0 ||
                        submitting)
                    ? null
                    : () => _submitAnswer(step, selectedAnswer!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                ),
                child: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Submit",
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------
  // FINAL CONGRATS SCREEN
  // ------------------------------------------

  Widget _buildCongratsScreen() {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_rounded, color: primaryColor, size: 100),
              const SizedBox(height: 20),
              Text("Congratulations!", style: bold20BlackText),
              const SizedBox(height: 10),
              Text(
                "You completed the Geo Quiz Journey!",
                textAlign: TextAlign.center,
                style: semibold14Grey,
              ),
              const SizedBox(height: 20),
              Text(
                "Your score: $score / ${quiz?.totalSteps ?? 0}",
                style: bold16BlackText.copyWith(color: primaryColor),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    score = 0;
                    currentStep = 0;
                    showCongrats = false;
                    showQuestion = false;
                    qrVerifiedForThisQuestion = false;
                    _generateNextQuestionLocation();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                ),
                child: const Text(
                  "Play Again",
                  style: TextStyle(color: whiteColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GeoQuizDetailsResponse {
  final bool error;
  final GeoQuiz data;

  GeoQuizDetailsResponse({
    required this.error,
    required this.data,
  });

  factory GeoQuizDetailsResponse.fromJson(Map<String, dynamic> json) {
    return GeoQuizDetailsResponse(
      error: json["error"] ?? false,
      data: GeoQuiz.fromJson(json["data"]),
    );
  }
}

class GeoQuiz {
  final int id;
  final String title;
  final String description;
  final String locationCity;
  final String locationCountry;
  final String themeCategory;
  final int minSteps;
  final int totalSteps;
  final int estimatedDuration;
  final String difficultyLevel;
  final int createdBy;
  final int status;
  final int isPublished;
  final String dateCreated;
  final String? dateUpdated;
  final String startDate;
  final String endDate;
  final int totalParticipants;
  final List<GeoQuizStep> steps;

  GeoQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.locationCity,
    required this.locationCountry,
    required this.themeCategory,
    required this.minSteps,
    required this.totalSteps,
    required this.estimatedDuration,
    required this.difficultyLevel,
    required this.createdBy,
    required this.status,
    required this.isPublished,
    required this.dateCreated,
    required this.dateUpdated,
    required this.startDate,
    required this.endDate,
    required this.totalParticipants,
    required this.steps,
  });

  factory GeoQuiz.fromJson(Map<String, dynamic> json) {
    return GeoQuiz(
      id: int.parse(json["id"]),
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      locationCity: json["location_city"] ?? "",
      locationCountry: json["location_country"] ?? "",
      themeCategory: json["theme_category"] ?? "",
      minSteps: int.parse(json["min_steps"]),
      totalSteps: int.parse(json["total_steps"]),
      estimatedDuration: int.parse(json["estimated_duration"]),
      difficultyLevel: json["difficulty_level"] ?? "",
      createdBy: int.parse(json["created_by"]),
      status: int.parse(json["status"]),
      isPublished: int.parse(json["is_published"]),
      dateCreated: json["date_created"] ?? "",
      dateUpdated: json["date_updated"],
      startDate: json["start_date"] ?? "",
      endDate: json["end_date"] ?? "",
      totalParticipants: int.parse(json["total_participants"]),
      steps:
          (json["steps"] as List).map((s) => GeoQuizStep.fromJson(s)).toList(),
    );
  }
}

class GeoQuizStep {
  final int id;
  final int stepNumber;
  final String question;
  final String option1;
  final String option2;
  final String option3;
  final int correctAnswer;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final int penaltyMinutes;
  final String hint;
  final String imageUrl;
  final int points;
  final int timeLimitSeconds;

  GeoQuizStep({
    required this.id,
    required this.stepNumber,
    required this.question,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.correctAnswer,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.penaltyMinutes,
    required this.hint,
    required this.imageUrl,
    required this.points,
    required this.timeLimitSeconds,
  });

  factory GeoQuizStep.fromJson(Map<String, dynamic> json) {
    return GeoQuizStep(
      id: int.parse(json["id"]),
      stepNumber: int.parse(json["step_number"]),
      question: json["question"] ?? "",
      option1: json["option_1"] ?? "",
      option2: json["option_2"] ?? "",
      option3: json["option_3"] ?? "",
      correctAnswer: int.parse(json["correct_answer"]),
      latitude: double.parse(json["latitude"]),
      longitude: double.parse(json["longitude"]),
      radiusMeters: int.parse(json["radius_meters"]),
      penaltyMinutes: int.parse(json["penalty_minutes"]),
      hint: json["hint"] ?? "",
      imageUrl: json["image_url"] ?? "",
      points: int.parse(json["points"]),
      timeLimitSeconds: int.parse(json["time_limit_seconds"]),
    );
  }
}

void printGeoQuizDetails(GeoQuizDetailsResponse res) {
  final q = res.data;

  print("=========== 🗺️ GEO QUIZ DETAILS ===========");
  print("ID: ${q.id}");
  print("Title: ${q.title}");
  print("Description: ${q.description}");
  print("Location: ${q.locationCity}, ${q.locationCountry}");
  print("Theme: ${q.themeCategory}");
  print("Difficulty: ${q.difficultyLevel}");
  print("Steps: ${q.minSteps}/${q.totalSteps}");
  print("Duration (min): ${q.estimatedDuration}");
  print("Created By: ${q.createdBy}");
  print("Published: ${q.isPublished == 1 ? "Yes" : "No"}");
  print("Total Participants: ${q.totalParticipants}");
  print("--------------------------------------------");
  print("Start Date: ${q.startDate}");
  print("End Date: ${q.endDate}");
  print("Created At: ${q.dateCreated}");
  print("Updated At: ${q.dateUpdated}");
  print("============================================");

  print("\n🧩 STEPS (${q.steps.length}):\n");

  for (final step in q.steps) {
    print("----- Step ${step.stepNumber} -----");
    print("ID: ${step.id}");
    print("Question: ${step.question}");
    print("Options:");
    print("  1) ${step.option1}");
    print("  2) ${step.option2}");
    print("  3) ${step.option3}");
    print("Correct Answer: ${step.correctAnswer}");
    print("Points: ${step.points}, Time Limit: ${step.timeLimitSeconds}s");
    print("GPS: (${step.latitude}, ${step.longitude})");
    print("Radius: ${step.radiusMeters} meters");
    print("Penalty: ${step.penaltyMinutes} minutes");
    print("Hint: ${step.hint.isEmpty ? "None" : step.hint}");
    print("Image: ${step.imageUrl.isEmpty ? "No image" : step.imageUrl}");
    print("----------------------------------\n");
  }
}
