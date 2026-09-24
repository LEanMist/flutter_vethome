import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_fab.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_weather_button.dart';
import './widgets/pet_card_widget.dart';

class PetsListScreen extends StatelessWidget {
  PetsListScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> _pets = [
    {
      "name": "Fernando",
      "imagePath": ImageConstant.imgCachorroegatoPng,

      "description":
          "Que tal experimentar um clássico feito na sua própria casa? Veja como preparar um brownie simples e rápido. Esta receita oferece uma maneira prática de criar esses deliciosos quadrados de chocolate, com ingredientes básicos como manteiga, ovos, achocolatado, açúcar e farinha de trigo.",
    },
    {
      "name": "Kelly",
      "imagePath": ImageConstant.imgCachorroegatoPng36x32,

      "description":
          "Que tal experimentar um clássico feito na sua própria casa? Veja como preparar um brownie simples e rápido. Esta receita oferece uma maneira prática de criar esses deliciosos quadrados de chocolate, com ingredientes básicos como manteiga, ovos, achocolatado, açúcar e farinha de trigo.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.red_100,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      _buildPetListSection(context),
                      _buildBottomNavRow(context),
                      CustomImageView(
                        imagePath: ImageConstant.imgImage2,
                        width: double.infinity,
                        height: 50.h,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 30.h,
            bottom: 62.h,
            child: CustomFab(
              imagePath: ImageConstant.imgFrame49,
              onTap: () {
                _onAddPetTapped(context);
              },
              backgroundColor: appTheme.red_100,
              buttonSize: 66.h,
              borderRadius: 32.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: appTheme.red_300,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.h),
          bottomRight: Radius.circular(30.h),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.h),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgVethomePng5,
                width: 84.h,
                height: 86.h,
                radius: BorderRadius.circular(42.h),
                fit: BoxFit.cover,
              ),
              SizedBox(width: 66.h),
              Text(
                'Pets',
                style: TextStyleHelper.instance.headline30BoldComfortaa
                    .copyWith(height: 34 / 30),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          CustomWeatherButton(
            width: double.infinity,
            text: '°  w  °',
            onTap: () {},
            textColor: appTheme.white_A700,
            backgroundColor: appTheme.color33C080,
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildPetListSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 22.h, left: 12.h, right: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 12.h),
      decoration: BoxDecoration(
        color: appTheme.color3FC080,
        borderRadius: BorderRadius.circular(24.h),
      ),
      child: Column(
        children: [
          ..._pets.asMap().entries.map((entry) {
            final index = entry.key;
            final pet = entry.value;
            return Column(
              children: [
                if (index > 0) SizedBox(height: 18.h),
                PetCardWidget(
                  name: pet['name'],
                  imagePath: pet['imagePath'],
                  description: pet['description'],
                  onTap: () => _onPetCardTapped(context, pet['name']),
                ),
              ],
            );
          }).toList(),
          SizedBox(height: 100.h),
          Align(
            alignment: Alignment.center,
            child: CustomImageView(
              imagePath: ImageConstant.imgFrame48,
              width: 106.h,
              height: 46.h,
              radius: BorderRadius.circular(22.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavRow(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 20.h, left: 12.h, right: 12.h),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.h),
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
      child: Row(
        children: [
          CustomIconButton(
            imagePath: ImageConstant.imgFrame48WhiteA700,
            backgroundColor: appTheme.color7FC080,
            padding: EdgeInsets.all(8.h),
            width: 66.h,
            height: 66.h,
            borderRadius: 32.h,
            onTap: () {},
          ),
          SizedBox(width: 22.h),
          CustomIconButton(
            imagePath: ImageConstant.imgFrame51,
            backgroundColor: appTheme.red_100,
            padding: EdgeInsets.all(18.h),
            width: 66.h,
            height: 66.h,
            borderRadius: 32.h,
            onTap: () => _onProfileTapped(context),
          ),
          SizedBox(width: 22.h),
          CustomIconButton(
            imagePath: ImageConstant.imgFrame50,
            backgroundColor: appTheme.red_100,
            padding: EdgeInsets.all(14.h),
            width: 66.h,
            height: 66.h,
            borderRadius: 32.h,
            onTap: () => _onAppointmentsTapped(context),
          ),
        ],
      ),
    );
  }

  void _onPetCardTapped(BuildContext context, String petName) {
    // Navigate to pet details screen
  }

  void _onAddPetTapped(BuildContext context) {
    // Navigate to add pet screen
  }

  void _onProfileTapped(BuildContext context) {
    // Navigate to profile screen
  }

  void _onAppointmentsTapped(BuildContext context) {
    // Navigate to appointments screen
  }
}
