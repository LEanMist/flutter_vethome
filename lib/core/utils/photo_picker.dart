import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/vet_colors.dart';

Future<XFile?> pickLocalPhoto(
  BuildContext context, {
  double maxSize = 800,
}) async {
  final cameraAvailable =
      kIsWeb || defaultTargetPlatform != TargetPlatform.windows;
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: VetColors.pink,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cameraAvailable)
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Escolher da galeria'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return null;
  return ImagePicker().pickImage(
    source: source,
    maxWidth: maxSize,
    maxHeight: maxSize,
    imageQuality: 75,
  );
}
