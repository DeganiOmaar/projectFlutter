import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class ChatService {
  static Future<String> sendMessage(List<Map<String, String>> messages) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse("${ApiConfig.baseUrl}/chat");
    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"messages": messages}),
    );

    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body["message"] ?? "Chat request failed");
    }

    final data = jsonDecode(res.body);
    return data["content"] ?? "";
  }
}
