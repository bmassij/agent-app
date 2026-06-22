import 'package:cursor_api_core/cursor_api_core.dart';

import 'package:cursor_mobile_commander/features/auth/domain/auth_model.dart';

/// HTTP calls for Cursor auth via [cursor_api_core].
class AuthRemoteSource {
  AuthRemoteSource({
    CursorHttpClient Function(String apiKey)? clientFactory,
  }) : _clientFactory = clientFactory ?? ((key) => CursorHttpClient(apiKey: key));

  final CursorHttpClient Function(String) _clientFactory;

  Future<CursorMeModel> fetchMe(String apiKey) {
    return _clientFactory(apiKey).fetchMe();
  }
}
