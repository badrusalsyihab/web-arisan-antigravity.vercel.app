import 'package:flutter/foundation.dart';

class DeepLinkService {
  static String? _pendingJoinCode;

  /// Initializes deep link parsing. 
  /// Currently only handles web query parameters for simplicity.
  static void initialize() {
    if (kIsWeb) {
      try {
        final uri = Uri.base;
        if (uri.queryParameters.containsKey('joinCode')) {
          _pendingJoinCode = uri.queryParameters['joinCode'];
        }
      } catch (e) {
        debugPrint('Error parsing deep link: $e');
      }
    }
  }

  /// Gets the pending join code and clears it from memory so it doesn't trigger again.
  static String? consumePendingJoinCode() {
    final code = _pendingJoinCode;
    _pendingJoinCode = null; // Clear after reading
    return code;
  }
}
