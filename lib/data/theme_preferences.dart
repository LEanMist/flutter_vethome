import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';

class ThemePreferences {
  ThemePreferences._();

  static const storageKey = 'vethome.themeSeed.v1';

  static const options = <({String name, Color color})>[
    (name: 'Marrom', color: Color(0xFF68442E)),
    (name: 'Rosa', color: Color(0xFFC08081)),
    (name: 'Verde', color: Color(0xFF718B70)),
    (name: 'Azul', color: Color(0xFF6B8FA3)),
    (name: 'Roxo', color: Color(0xFF9477A8)),
  ];

  static Future<void> load() async {
    try {
      final stored = (await SharedPreferences.getInstance()).getInt(storageKey);
      if (stored == null ||
          !options.any((option) => option.color.toARGB32() == stored)) {
        return;
      }
      VH.themeSeed.value = Color(stored);
    } catch (_) {
      debugPrint('VetHome: preferência de tema local indisponível.');
    }
  }

  static Future<bool> save(Color color) async {
    final value = color.toARGB32();
    if (!options.any((option) => option.color.toARGB32() == value)) {
      return false;
    }
    try {
      final preferences = await SharedPreferences.getInstance();
      return await preferences.setInt(storageKey, value);
    } catch (_) {
      debugPrint('VetHome: não foi possível salvar a preferência de tema.');
      return false;
    }
  }
}
