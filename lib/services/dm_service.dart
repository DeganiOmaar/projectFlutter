import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/api_config.dart';
import 'auth_service.dart';

class DmService {
  static Future<List<Map<String, dynamic>>> getPeers() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse("${ApiConfig.baseUrl}/dm/peers");
    final res = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)["message"] ?? "Failed to get peers");
    }

    final data = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(data["peers"] ?? []);
  }

  static Future<int> getTotalUnread() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse("${ApiConfig.baseUrl}/dm/unread-total");
    final res = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      return 0;
    }
    final data = jsonDecode(res.body);
    return (data["totalUnread"] ?? 0) as int;
  }

  static Future<Map<String, dynamic>> getConversation(String peerId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse("${ApiConfig.baseUrl}/dm/conversation/$peerId");
    final res = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)["message"] ?? "Failed to get conversation");
    }

    return jsonDecode(res.body);
  }

  static Future<void> markConversationRead(String peerId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse("${ApiConfig.baseUrl}/dm/conversation/$peerId/read");
    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)["message"] ?? "Failed to mark as read");
    }
  }

  static Future<io.Socket> connectSocket() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("Not authenticated");

    final socket = io.io(
      ApiConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(["websocket"])
          .enableAutoConnect()
          .setAuth({"token": token})
          .build(),
    );

    return socket;
  }
}
