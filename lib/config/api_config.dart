class ApiConfig {
  static const String baseUrl = "http://10.0.2.2:3000";

  /// Socket.IO connects to same host as HTTP API
  static String get socketUrl => baseUrl;
}
