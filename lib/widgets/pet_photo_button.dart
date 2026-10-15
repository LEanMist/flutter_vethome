import 'package:flutter/material.dart';
import '../theme/vet_colors.dart';

/// Small visual badge inside a transparent, accessible hit target.
class PetPhotoButton extends StatelessWidget {
  const PetPhotoButton({super.key, this.onPressed, this.busy = false});
  final VoidCallback? onPressed;
  final bool busy;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 40,
    height: 40,
    child: IconButton(
      tooltip: 'Alterar foto do pet',
      onPressed: busy ? null : onPressed,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(backgroundColor: Colors.transparent),
      icon: Container(
        key: const ValueKey('pet-camera-badge'),
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: VetColors.brown,
          shape: BoxShape.circle,
          border: Border.all(color: VetColors.pink, width: 1.5),
        ),
        child: Icon(
          busy ? Icons.hourglass_top : Icons.photo_camera_outlined,
          size: 15,
          color: Colors.white,
        ),
      ),
    ),
  );
}
