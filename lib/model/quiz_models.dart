import 'package:google_maps_flutter/google_maps_flutter.dart';

class Question {
  final int stepNumber;
  final String question;
  final String option1;
  final String option2;
  final String option3;
  final int points;
  final int timeLimitSeconds;
  final double latitude;
  final double longitude;

  Question({
    required this.stepNumber,
    required this.question,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.points,
    required this.timeLimitSeconds,
    required this.latitude,
    required this.longitude,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      stepNumber: int.parse(json['step_number'].toString()),
      question: json['question'] ?? '',
      option1: json['option_1'] ?? '',
      option2: json['option_2'] ?? '',
      option3: json['option_3'] ?? '',
      points: int.parse(json['points'].toString()),
      timeLimitSeconds: int.parse(json['time_limit_seconds'].toString()),
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
    );
  }

  LatLng get location => LatLng(latitude, longitude);
}

class QuizAnswerResponse {
  final bool isCorrect;
  final int? correctAnswer;
  final int pointsEarned;
  final int timePenaltySeconds;
  final int totalScore;
  final int currentStep;
  final String message;
  final bool inPenalty;
  final int penaltyRemainingSeconds;

  QuizAnswerResponse({
    this.isCorrect = false,
    this.correctAnswer,
    this.pointsEarned = 0,
    this.timePenaltySeconds = 0,
    this.totalScore = 0,
    this.currentStep = 0,
    this.message = '',
    this.inPenalty = false,
    this.penaltyRemainingSeconds = 0,
  });

  factory QuizAnswerResponse.fromJson(Map<String, dynamic> json) {
    return QuizAnswerResponse(
      isCorrect: json['is_correct'] == true || json['is_correct'] == 1,
      correctAnswer: int.tryParse(json['correct_answer'].toString()),
      pointsEarned: int.tryParse(json['points_earned'].toString()) ?? 0,
      timePenaltySeconds: int.tryParse(json['time_penalty_seconds'].toString()) ?? 0,
      totalScore: int.tryParse(json['total_score'].toString()) ?? 0,
      currentStep: int.tryParse(json['current_step'].toString()) ?? 0,
      message: json['message'] ?? '',
      inPenalty: json['in_penalty'] == true,
      penaltyRemainingSeconds: int.tryParse(json['penalty_remaining_seconds'].toString()) ?? 0,
    );
  }
}

class GeoQuiz {
  final int id;
  final String title;
  final String description;

  GeoQuiz({required this.id, required this.title, required this.description});

  factory GeoQuiz.fromJson(Map<String, dynamic> json) {
    return GeoQuiz(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
