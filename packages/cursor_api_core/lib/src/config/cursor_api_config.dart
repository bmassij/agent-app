/// Cursor API v1 configuration.
abstract final class CursorApiConfig {
  static const String baseUrl = 'https://api.cursor.com/v1';

  static const Duration connectTimeout = Duration(seconds: 15);

  static const Duration receiveTimeout = Duration(seconds: 30);
}
