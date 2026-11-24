import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl => const String.fromEnvironment(
        'API_URL',
        defaultValue: kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080',
      );
}
