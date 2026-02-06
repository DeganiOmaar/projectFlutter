import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class UserService {
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse("${ApiConfig.baseUrl}/user/me");
    final res = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)["message"] ?? "Failed to get profile");
    }

    return jsonDecode(res.body)["user"];
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String nom,
    required String prenom,
    required int age,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse("${ApiConfig.baseUrl}/user/update");
    final res = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "nom": nom,
        "prenom": prenom,
        "age": age,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)["message"] ?? "Failed to update profile");
    }

    return jsonDecode(res.body)["user"];
  }
}
