import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_fab_button.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_image_view.dart';

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String _profileName = "Liminha";
  String _dateOfBirth = "05 / 02 / 2007";
  String? _profileImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  void _showChangePhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: appTheme.red_100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.h)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Mudar Foto de Perfil",
                  style: TextStyleHelper.instance.title18BoldComfortaa,
                ),
                SizedBox(height: 20.h),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: appTheme.gray_800),
                  title: Text(
                    "Câmera",
                    style: TextStyleHelper.instance.title16Comfortaa,
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: appTheme.gray_800),
                  title: Text(
                    "Galeria",
                    style: TextStyleHelper.instance.title16Comfortaa,
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      _showErrorSnackBar("Não foi possível selecionar a foto.");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: appTheme.red_300),
    );
  }

  void _showChangeNameDialog() {
    final TextEditingController nameController = TextEditingController(
      text: _profileName,
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: appTheme.red_100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.h),
          ),
          title: Text(
            "Mudar Nome de Perfil",
            style: TextStyleHelper.instance.title18BoldComfortaa,
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              style: TextStyleHelper.instance.title16Comfortaa,
              decoration: InputDecoration(
                hintText: "Digite o novo nome",
                hintStyle: TextStyleHelper.instance.body14Comfortaa.copyWith(
                  color: Color(0xFF68442E).withAlpha(128),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: appTheme.red_300),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: appTheme.gray_800),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Por favor, insira um nome válido.";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancelar",
                style: TextStyleHelper.instance.bodyTextComfortaa,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.red_300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.h),
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _profileName = nameController.text.trim();
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(
                "Salvar",
                style: TextStyleHelper.instance.bodyTextComfortaa.copyWith(
                  color: appTheme.white_A700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showChangeDateOfBirthPicker() async {
    DateTime initialDate = DateTime(2007, 2, 5);
    try {
      final parts = _dateOfBirth.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0].trim());
        final month = int.tryParse(parts[1].trim());
        final year = int.tryParse(parts[2].trim());
        if (day != null && month != null && year != null) {
          initialDate = DateTime(year, month, day);
        }
      }
    } catch (_) {}

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appTheme.red_300,
              onPrimary: appTheme.white_A700,
              onSurface: appTheme.gray_800,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: appTheme.gray_800),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth =
            "${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.red_100,
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeaderSection(),
                      SizedBox(height: 12.h),
                      _buildDateOfBirthRow(),
                      SizedBox(height: 58.h),
                      _buildMenuItems(),
                      SizedBox(height: 96.h),
                      _buildBottomNavBar(),
                      _buildBottomImage(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(right: 30.h, bottom: 62.h),
              child: CustomFabButton(
                onPressed: _showChangePhotoOptions,
                imagePath: ImageConstant.imgFrame49,
                backgroundColor: appTheme.red_100,
                buttonSize: 66.h,
                borderRadius: 32.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return SizedBox(
      width: double.infinity,
      height: 368.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: appTheme.red_300,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.h),
                  bottomRight: Radius.circular(30.h),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 42.h),
                    child: CustomImageView(
                      imagePath: ImageConstant.imgVethomePng5,
                      height: 86.h,
                      width: 84.h,
                      radius: BorderRadius.circular(42.h),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 58.h),
                  Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: Text(
                      "Perfil",
                      style: TextStyleHelper.instance.headline30BoldComfortaa
                          .copyWith(height: 34 / 30),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: _buildProfileCard()),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.54,
      decoration: BoxDecoration(
        color: appTheme.color7FFAD3,
        border: Border.all(color: appTheme.red_300, width: 5.h),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.h),
          topRight: Radius.circular(30.h),
          bottomLeft: Radius.circular(100.h),
          bottomRight: Radius.circular(100.h),
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.black_900_3f,
            offset: Offset(2, 2),
            blurRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 2.h),
          Text(
            _profileName,
            style: TextStyleHelper.instance.title22BoldComfortaa.copyWith(
              height: 25 / 22,
            ),
          ),
          SizedBox(height: 32.h),
          _buildProfilePhotoCircle(),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoCircle() {
    return GestureDetector(
      onTap: _showChangePhotoOptions,
      child: Container(
        width: 182.h,
        height: 182.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: appTheme.color7F6844, width: 3.h),
        ),
        child: ClipOval(
          child: _profileImagePath != null
              ? Image.file(
                  File(_profileImagePath!),
                  width: 164.h,
                  height: 164.h,
                  fit: BoxFit.cover,
                )
              : CustomImageView(
                  imagePath: ImageConstant.imgImages11,
                  height: 164.h,
                  width: 164.h,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomImageView(
          imagePath: ImageConstant.imgVector,
          height: 22.h,
          width: 18.h,
        ),
        SizedBox(width: 8.h),
        Text(
          _dateOfBirth,
          style: TextStyleHelper.instance.title18BoldComfortaa.copyWith(
            height: 21 / 18,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        _buildMenuItem(
          title: "Mudar Foto de Perfil",
          onTap: _showChangePhotoOptions,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12.h, vertical: 16.h),
          height: 1.h,
          color: appTheme.color3F6844,
        ),
        _buildMenuItem(
          title: "Mudar Nome de Perfil",
          onTap: _showChangeNameDialog,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12.h, vertical: 16.h),
          height: 1.h,
          color: appTheme.color3F6844,
        ),
        _buildMenuItem(
          title: "Mudar Data de Nascimento",
          onTap: _showChangeDateOfBirthPicker,
        ),
      ],
    );
  }

  Widget _buildMenuItem({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyleHelper.instance.title18BoldComfortaa.copyWith(
                height: 21 / 18,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomImageView(
                imagePath: ImageConstant.imgVectorGray800,
                height: 16.h,
                width: 8.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.h),
      padding: EdgeInsets.only(top: 12.h, bottom: 12.h, left: 16.h),
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
            imagePath: ImageConstant.imgFrame48,
            backgroundColor: appTheme.red_100,
            padding: EdgeInsets.all(8.h),
            onTap: () {},
          ),
          CustomIconButton(
            imagePath: ImageConstant.imgFrame51,
            backgroundColor: appTheme.color7FC080,
            padding: EdgeInsets.all(18.h),
            margin: EdgeInsets.only(left: 22.h),
            onTap: () {},
          ),
          CustomIconButton(
            imagePath: ImageConstant.imgFrame50,
            backgroundColor: appTheme.red_100,
            padding: EdgeInsets.all(14.h),
            margin: EdgeInsets.only(left: 22.h),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBottomImage() {
    return CustomImageView(
      imagePath: ImageConstant.imgImage6,
      width: double.infinity,
      height: 50.h,
      fit: BoxFit.cover,
    );
  }
}
