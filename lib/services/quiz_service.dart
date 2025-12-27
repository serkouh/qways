import 'dart:convert';
import 'package:qways/constant/apiservice.dart';
import 'package:qways/model/quiz_models.dart';

class QuizService {
  // Create a room for a specific quiz
  static Future<Map<String, dynamic>> createRoom({
    required int quizId,
    required String roomName,
    int maxParticipants = 100,
  }) async {
    final res = await ApiService.post(
      endpoint: "create_geo_quiz_room",
      body: {
        "geo_quiz_id": quizId,
        "room_name": roomName,
        "max_participants": maxParticipants,
        "room_type": "public",
      },
      withAuth: true,
    );
    return ApiService.decodeResponse(res);
  }

  // Join a room by UUID
  static Future<Map<String, dynamic>> joinRoom(String roomUuid) async {
    final res = await ApiService.post(
      endpoint: "join_geo_quiz_room",
      body: {"room_uuid": roomUuid},
      withAuth: true,
    );
    return ApiService.decodeResponse(res);
  }

  // Start the quiz (Host only)
  static Future<Map<String, dynamic>> startQuiz(String roomUuid) async {
    final res = await ApiService.post(
      endpoint: "start_room_quiz",
      body: {"room_uuid": roomUuid},
      withAuth: true,
    );
    return ApiService.decodeResponse(res);
  }

  // Get questions for the room
  static Future<List<Question>> getQuestions(String roomUuid) async {
    final res = await ApiService.post(
      endpoint: "get_room_quiz_questions",
      body: {"room_uuid": roomUuid},
      withAuth: true,
    );
    
    final data = ApiService.decodeResponse(res);
    if (data['data'] != null && data['data']['questions'] != null) {
      return (data['data']['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList();
    }
    return [];
  }

  // Submit an answer
  static Future<QuizAnswerResponse> submitAnswer({
    required String roomUuid,
    required int stepNumber,
    required int selectedAnswer,
    required double lat,
    required double lng,
    required int timeTaken,
  }) async {
    final res = await ApiService.post(
      endpoint: "submit_room_quiz_answer",
      body: {
        "room_uuid": roomUuid,
        "step_number": stepNumber,
        "selected_answer": selectedAnswer,
        "latitude": lat,
        "longitude": lng,
        "time_taken": timeTaken,
      },
      withAuth: true,
    );

    final data = ApiService.decodeResponse(res);

    // Check for penalty error response structure
    if (data['error'] == true || data['in_penalty'] == true) {
       // Ideally the API would return consistent structure, but we handle the error case here
       // Assuming the response body contains penalty info even on error
       return QuizAnswerResponse.fromJson(data['data'] ?? data);
    }
    
    return QuizAnswerResponse.fromJson(data['data'] ?? data);
  }

  // Get quiz history (for resuming)
  static Future<Map<String, dynamic>?> getCurrentGame() async {
    final res = await ApiService.post(
      endpoint: "get_geo_quiz_history",
      body: {
        "limit": 1,
        "status": "playing",
      },
      withAuth: true,
    );

    final data = ApiService.decodeResponse(res);
    if (data['data'] != null && data['data']['history'] != null) {
      final history = data['data']['history'] as List;
      if (history.isNotEmpty) {
        return history[0];
      }
    }
    return null;
  }
  
  // Get all active quizzes to display in list
   static Future<List<GeoQuiz>> getActiveQuizzes() async {
    final res = await ApiService.post(
      endpoint: "get_geo_quizzes",
      body: {"status": 1},
      withAuth: true,
    );
    
    final data = ApiService.decodeResponse(res);
    if (data['data'] != null) {
      return (data['data'] as List).map((q) => GeoQuiz.fromJson(q)).toList();
    }
    return [];
  }

  // Get all active rooms (Public Explorer)
  static Future<List<dynamic>> getAllLiveRooms() async {
    final res = await ApiService.post(
      endpoint: "get_all_live_rooms",
      body: {}, // No filter needed for all
      withAuth: true,
    );
    
    final data = ApiService.decodeResponse(res);
    if (data['data'] != null && data['data'] is List) {
      return data['data'];
    }
    return [];
  }
}
