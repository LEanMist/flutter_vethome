import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

/// Dados independentes do perfil da veterinária.
class GabrielaProfileRepository {
  GabrielaProfileRepository._();

  static const _nameKey = 'vethome.gabriela.name';
  static const _birthDateKey = 'vethome.gabriela.birthDate';

  static String name = 'Liminha';
  static DateTime birthDate = DateTime(2007, 2, 5);
  // Como no perfil do cliente, a foto fica disponível durante a sessão.
  static Uint8List? photoBytes;

  static Future<void> initialize() async {
    name = 'Liminha';
    birthDate = DateTime(2007, 2, 5);
    photoBytes = null;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.reload();
      final savedName = preferences.getString(_nameKey);
      if (savedName != null && savedName.trim().isNotEmpty) name = savedName;
      final savedDate = preferences.getString(_birthDateKey);
      if (savedDate != null) {
        birthDate = DateTime.tryParse(savedDate) ?? birthDate;
      }
    } catch (_) {
      // Mantém os valores iniciais se o armazenamento estiver indisponível.
    }
  }

  static Future<void> updateName(String value) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(_nameKey, value)) {
      throw StateError('Não foi possível salvar o nome.');
    }
    name = value;
  }

  static Future<void> updateBirthDate(DateTime value) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(_birthDateKey, value.toIso8601String())) {
      throw StateError('Não foi possível salvar a data de nascimento.');
    }
    birthDate = value;
  }
}
