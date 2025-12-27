import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ✅ Base URL for all your API calls
  static const String baseUrl = "https://quizzapi.devarch-digital.com/Api/";

  // ✅ Build headers dynamically
  static Future<Map<String, String>> _headers({bool withAuth = false}) async {
    final headers = {"Content-Type": "application/json"};
    if (withAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("api_token");
      print(token);
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  // ✅ Construct full URL
  static String _buildUrl(String endpoint) => "$baseUrl$endpoint";

  // ✅ GET request
  static Future<http.Response> get({
    required String endpoint,
    Map<String, dynamic>? params,
    bool withAuth = false,
  }) async {
    final headers = await _headers(withAuth: withAuth);
    final uri = Uri.parse(_buildUrl(endpoint)).replace(queryParameters: params);
    final res = await http.get(uri, headers: headers);
    _log(endpoint, res.statusCode);
    return res;
  }

  // ✅ POST request
  static Future<http.Response> post({
    required String endpoint,
    Map<String, dynamic>? body,
    bool withAuth = false,
  }) async {
    final headers = await _headers(withAuth: withAuth);
    final uri = Uri.parse(_buildUrl(endpoint));
    final res =
        await http.post(uri, headers: headers, body: jsonEncode(body ?? {}));
    _log(endpoint, res.statusCode, body);
    return res;
  }

  // ✅ PUT request
  static Future<http.Response> put({
    required String endpoint,
    Map<String, dynamic>? body,
    bool withAuth = false,
  }) async {
    final headers = await _headers(withAuth: withAuth);
    final uri = Uri.parse(_buildUrl(endpoint));
    final res =
        await http.put(uri, headers: headers, body: jsonEncode(body ?? {}));
    _log(endpoint, res.statusCode, body);
    return res;
  }

  // ✅ POST Multipart request (for file uploads)
  static Future<http.Response> postMultipart({
    required String endpoint,
    required String filePath,
    Map<String, String>? fields,
    bool withAuth = false,
  }) async {
    final uri = Uri.parse(_buildUrl(endpoint));
    final request = http.MultipartRequest('POST', uri);

    // Add Headers
    final headers = await _headers(withAuth: withAuth);
    request.headers.addAll(headers);
    // Remove Content-Type as MultipartRequest sets it automatically
    request.headers.remove('Content-Type');

    // Add Fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Add File
    if (filePath.isNotEmpty) {
      final file = await http.MultipartFile.fromPath('image', filePath);
      request.files.add(file);
    }

    print("📡 Uploading to $endpoint...");
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    _log(endpoint, response.statusCode);
    return response;
  }

  // ✅ DELETE request
  static Future<http.Response> delete({
    required String endpoint,
    bool withAuth = false,
  }) async {
    final headers = await _headers(withAuth: withAuth);
    final uri = Uri.parse(_buildUrl(endpoint));
    final res = await http.delete(uri, headers: headers);
    _log(endpoint, res.statusCode);
    return res;
  }

  // ✅ Decode JSON safely
  static dynamic decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      return {"error": "Invalid JSON response", "raw": response.body};
    }
  }

  // ✅ Debug logger
  static void _log(String endpoint, int statusCode,
      [Map<String, dynamic>? body]) {
    print("📡 [$statusCode] → $endpoint");
    if (body != null) print("🧾 Body: $body");
  }
}

String getApiMessage(dynamic response) {
  try {
    if (response == null) return "Unknown error";

    // Convert to Map if it's a JSON string
    Map<String, dynamic> json;
    if (response is String) {
      json = jsonDecode(response);
    } else {
      json = response;
    }

    final code = json["message"]?.toString().trim() ?? "";

    // Map of all messages
    const messages = {
      "101": "Invalid access key",
      "102": "Data not found",
      "103": "Please fill all the required fields",
      "104": "User registered successfully",
      "105": "Successfully logged in",
      "106": "Profile updated successfully",
      "107": "File upload failed",
      "108": "Battle destroyed successfully",
      "109": "Report submitted successfully",
      "110": "Data inserted successfully",
      "111": "Data updated successfully",
      "112": "Daily quiz already played",
      "113": "No matches played yet",
      "114": "No upcoming contest available",
      "115": "No contest available right now",
      "116": "You have not played any contest yet",
      "117": "Contest you have played",
      "118": "Play & win exciting prizes",
      "119": "Room is already created",
      "120": "Room created successfully",
      "121": "Room destroyed successfully",
      "122": "Something went wrong",
      "123": "Notification sent successfully",
      "124": "Invalid hash value",
      "125": "Unauthorized access not allowed",
      "126": "Your account has been deactivated. Contact admin.",
      "127": "You already made a payment request. Wait 48 hours.",
      "128": "Already played",
      "129": "Unauthorized access",
      "130": "User already exists",
      "131": "User does not exist",
      "132": "Data already exists",
      "133": "Daily ads limit reached",
      "134": "You may continue",
      "135": "Payment request is not pending",
      "136": "Coins already redeemed",
    };

    return messages[code] ?? "Unknown response ($code)";
  } catch (e) {
    return "Error parsing response";
  }
}
