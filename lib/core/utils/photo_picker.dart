import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/vet_colors.dart';
import '../../widgets/vet/vet_centered_dialog.dart';

Future<XFile?> pickLocalPhoto(
  BuildContext context, {
  double maxSize = 800,
  bool centered = false,
}) async {
  final cameraAvailable =
      kIsWeb || defaultTargetPlatform != TargetPlatform.windows;
  Widget sourceOptions(BuildContext ctx) => SafeArea(
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
  );
  final source = centered
      ? await showVetCenteredDialog<ImageSource>(
          context: context,
          builder: sourceOptions,
        )
      : await showModalBottomSheet<ImageSource>(
          context: context,
          backgroundColor: VetColors.pink,
          builder: sourceOptions,
        );
  if (source == null) return null;
  return ImagePicker().pickImage(
    source: source,
    maxWidth: maxSize,
    maxHeight: maxSize,
    imageQuality: 75,
  );
}
