import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/pet_photo.dart';

/// Dados independentes do perfil da veterinária neste dispositivo.
class GabrielaProfileRepository {
  GabrielaProfileRepository._();

  static const _nameKey = 'vethome.gabriela.name';
  static const _birthDateKey = 'vethome.gabriela.birthDate';
  static const _photoKey = 'vethome.gabriela.photo.v1';
  static const _defaultName = 'Gabriela';
  static final firstBirthDate = DateTime(1920);

  static String _name = _defaultName;
  static DateTime? _birthDate;
  static Uint8List? _photoBytes;
  static bool _readFailed = false;

  static String get name => _name;
  static DateTime? get birthDate => _birthDate;
  static Uint8List? get photoBytes => _photoBytes;
  static bool get readFailed => _readFailed;

  static Future<void> initialize() async {
    _name = _defaultName;
    _birthDate = null;
    _photoBytes = null;
    _readFailed = false;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.reload();
      final savedName = preferences.get(_nameKey);
      if (savedName is String && savedName.trim().isNotEmpty) {
        _name = savedName.trim();
      } else if (savedName != null) {
        _readFailed = true;
      }

      final savedDate = preferences.get(_birthDateKey);
      if (savedDate != null) {
        final date = savedDate is String ? DateTime.tryParse(savedDate) : null;
        if (date != null && _validBirthDate(date)) {
          _birthDate = DateTime(date.year, date.month, date.day);
        } else {
          _readFailed = true;
        }
      }

      final savedPhoto = preferences.get(_photoKey);
      if (savedPhoto is String) {
        _photoBytes = await _decodePhoto(savedPhoto);
      } else if (savedPhoto != null) {
        _readFailed = true;
      }
    } catch (_) {
      _readFailed = true;
    }
  }

  static Future<void> updateName(String value) async {
    final name = value.trim();
    if (name.isEmpty) throw const FormatException('Preencha o nome.');
    await _save(_nameKey, name);
    _name = name;
  }

  static Future<void> updateBirthDate(DateTime value) async {
    final date = DateTime(value.year, value.month, value.day);
    if (!_validBirthDate(date)) {
      throw const FormatException('Escolha uma data de nascimento válida.');
    }
    await _save(_birthDateKey, date.toIso8601String());
    _birthDate = date;
  }

  static Future<void> updatePhoto(String value) async {
    final bytes = await _decodePhoto(value);
    await _save(_photoKey, value);
    _photoBytes = bytes;
  }

  static bool _validBirthDate(DateTime date) =>
      !date.isBefore(firstBirthDate) && !date.isAfter(DateTime.now());

  static Future<void> _save(String key, String value) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(key, value)) {
      throw StateError('Não foi possível salvar o perfil da Gabriela.');
    }
  }

  static Future<Uint8List> _decodePhoto(String value) async {
    const invalidPhoto = FormatException('Escolha uma foto válida.');
    if (!PetPhoto.isValid(value)) throw invalidPhoto;
    final bytes = base64Decode(value);
    // O PNG em miniatura tem dimensões no cabeçalho IHDR. Verifique-as
    // antes de decodificar imagens que vieram do armazenamento local.
    if (bytes.length < 24 ||
        bytes[12] != 0x49 ||
        bytes[13] != 0x48 ||
        bytes[14] != 0x44 ||
        bytes[15] != 0x52) {
      throw invalidPhoto;
    }
    final header = ByteData.sublistView(bytes);
    final width = header.getUint32(16);
    final height = header.getUint32(20);
    if (width == 0 ||
        height == 0 ||
        width > PetPhoto.maxThumbnailDimension ||
        height > PetPhoto.maxThumbnailDimension) {
      throw invalidPhoto;
    }

    final codec = await ui.instantiateImageCodec(bytes);
    try {
      final frame = await codec.getNextFrame();
      frame.image.dispose();
    } finally {
      codec.dispose();
    }
    return bytes.asUnmodifiableView();
  }
}
