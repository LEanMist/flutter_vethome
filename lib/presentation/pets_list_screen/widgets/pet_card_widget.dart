import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_view.dart';

class PetCardWidget extends StatelessWidget {
  final String name;
  final String imagePath;
  final String description;
  final VoidCallback? onTap;

  PetCardWidget({
    Key? key,
    required this.name,
    required this.imagePath,
    required this.description,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: 8.h,
          right: 18.h,
          bottom: 8.h,
          left: 18.h,
        ),
        decoration: BoxDecoration(
          color: appTheme.color7FC080,
          borderRadius: BorderRadius.circular(24.h),
          boxShadow: [
            BoxShadow(
              color: appTheme.black_900_3f,
              offset: Offset(2, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.h,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: CustomImageView(
                    imagePath: imagePath,
                    width: 32.h,
                    height: 36.h,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 8.h),
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    name,
                    style: TextStyleHelper.instance.title20BoldComfortaa
                        .copyWith(height: 23 / 20),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Text(
                description,
                style: TextStyleHelper.instance.label10BoldComfortaa.copyWith(
                  height: 11 / 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
