import 'package:flutter/foundation.dart';

class DeepLinkService {
  static String? _pendingJoinCode;

  /// Initializes deep link parsing. 
  /// Currently only handles web query parameters for simplicity.
  static void initialize() {
    if (kIsWeb) {
      try {
        final uri = Uri.base;
        
        // Check normal query parameters
        if (uri.queryParameters.containsKey('joinCode')) {
          _pendingJoinCode = uri.queryParameters['joinCode'];
          return;
        }
        
        // In Flutter Web, query params might get shifted to the fragment (e.g. /#/?joinCode=XYZ)
        if (uri.hasFragment) {
          final fragmentUri = Uri.parse(uri.fragment);
          if (fragmentUri.queryParameters.containsKey('joinCode')) {
            _pendingJoinCode = fragmentUri.queryParameters['joinCode'];
          }
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
