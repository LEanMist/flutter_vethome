import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/pet_photo.dart';

/// Dados independentes do perfil da veterinária.
class GabrielaProfileRepository {
  GabrielaProfileRepository._();

  static const _nameKey = 'vethome.gabriela.name';
  static const _birthDateKey = 'vethome.gabriela.birthDate';

  static const _photoKey = 'vethome.gabriela.photo.v1';
  static const _defaultName = 'Gabriela';

  static String name = _defaultName;
  static DateTime? birthDate;
  static Uint8List? _photoBytes;

  static Uint8List? get photoBytes => _photoBytes;

  static Future<void> initialize() async {
    name = _defaultName;
    birthDate = null;
    _photoBytes = null;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.reload();
      final savedName = preferences.getString(_nameKey);
      if (savedName != null && savedName.trim().isNotEmpty) name = savedName;
      final savedDate = preferences.get(_birthDateKey);
      if (savedDate is String) {
        final date = DateTime.tryParse(savedDate);
        if (date != null &&
            date.year >= 1920 &&
            !date.isAfter(DateTime.now())) {
          birthDate = date;
        }
      }
      final savedPhoto = preferences.get(_photoKey);
      if (savedPhoto is String && PetPhoto.isValid(savedPhoto)) {
        _photoBytes = base64Decode(savedPhoto);
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

  static Future<void> updatePhoto(String photo) async {
    if (!PetPhoto.isValid(photo)) {
      throw const FormatException('Foto de perfil inválida.');
    }
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(_photoKey, photo)) {
      throw StateError('Não foi possível salvar a foto.');
    }
    _photoBytes = base64Decode(photo);
  }

  static Future<void> updateBirthDate(DateTime value) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(_birthDateKey, value.toIso8601String())) {
      throw StateError('Não foi possível salvar a data de nascimento.');
    }
    birthDate = value;
  }
}
