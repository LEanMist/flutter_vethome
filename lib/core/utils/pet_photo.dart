import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'photo_picker.dart';

/// Small local PNG thumbnails; no blob URLs or file paths in saved photos.
class PetPhoto {
  static const maxEncodedLength = 180000;
  static const maxTotalEncodedLength = 1500000;
  static bool isValid(String value) {
    if (value.isEmpty || value.length > maxEncodedLength) return false;
    try {
      final bytes = base64Decode(value);
      return bytes.length >= 8 &&
          bytes[0] == 137 &&
          bytes[1] == 80 &&
          bytes[2] == 78 &&
          bytes[3] == 71;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> choose(BuildContext context) async {
    final picked = await pickLocalPhoto(context, maxSize: 512);
    if (picked == null) return null;
    if (await picked.length() > 5 * 1024 * 1024) {
      throw const FormatException('Escolha uma imagem menor que 5 MB.');
    }
    final bytes = await picked.readAsBytes();
    ui.Codec? codec;
    ui.Image? image;
    try {
      // ImageDescriptor.width/height are unsupported for encoded images on Web.
      // Read dimensions from a decoded frame, which works on every renderer.
      codec = await ui.instantiateImageCodec(bytes);
      image = (await codec.getNextFrame()).image;
      final scale = math.min(1.0, 256 / math.max(image.width, image.height));
      if (scale < 1) {
        final width = math.max(1, (image.width * scale).round());
        final height = math.max(1, (image.height * scale).round());
        image.dispose();
        image = null;
        codec.dispose();
        codec = null;
        codec = await ui.instantiateImageCodec(
          bytes,
          targetWidth: width,
          targetHeight: height,
          allowUpscaling: false,
        );
        image = (await codec.getNextFrame()).image;
      }
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw const FormatException('Não foi possível abrir a imagem.');
      }
      final encoded = base64Encode(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      if (!isValid(encoded)) {
        throw const FormatException('Escolha uma foto menor.');
      }
      return encoded;
    } finally {
      image?.dispose();
      codec?.dispose();
    }
  }
}
