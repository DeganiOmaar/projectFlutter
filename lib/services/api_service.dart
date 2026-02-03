

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:project/config/api_config.dart';

class ApiService {
  static Future<Map<String, dynamic>> ping ()async{
    final url = Uri.parse("${ApiConfig.baseUrl}/ping");
    final res = await http.get(url);

    if (res.statusCode != 200 ){
      throw Exception("Failed to connect");
    }
    return jsonDecode(res.body) as Map<String, dynamic>;

  }
}