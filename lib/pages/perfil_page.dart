// ignore_for_file: unused_element, unused_field, unused_parameter
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

// ---------------------------------------------------------------------------
// SIZE UTILS (inline)
// ---------------------------------------------------------------------------
const num _kFigmaDesignWidth = 390;

extension _ResponsiveExtension on num {
  double get h => ((this * _SizeUtils.width) / _kFigmaDesignWidth);
  double get fSize => ((this * _SizeUtils.width) / _kFigmaDesignWidth);
}

extension _FormatExtension on double {
  double isNonZero({num defaultValue = 0.0}) =>
      this > 0 ? this : defaultValue.toDouble();
}

class _SizeUtils {
  static late BoxConstraints boxConstraints;
  static late Orientation orientation;
  static late double height;
  static late double width;

  static void setScreenSize(
    BoxConstraints constraints,
    Orientation currentOrientation,
  ) {
    boxConstraints = constraints;
    orientation = currentOrientation;
    if (orientation == Orientation.portrait) {
      width = boxConstraints.maxWidth.isNonZero(
        defaultValue: _kFigmaDesignWidth,
      );
      height = boxConstraints.maxHeight.isNonZero();
    } else {
      width = boxConstraints.maxHeight.isNonZero(
        defaultValue: _kFigmaDesignWidth,
      );
      height = boxConstraints.maxWidth.isNonZero();
    }
  }
}

// ---------------------------------------------------------------------------
// THEME COLORS (inline)
// ---------------------------------------------------------------------------
class _AppColors {
  Color get white_A700 => const Color(0xFFFFFFFF);
  Color get red_300 => const Color(0xFFC08081);
  Color get gray_800 => const Color(0xFF68442E);
  Color get red_100 => const Color(0xFFFAD3D5);
  Color get black_900_3f => const Color(0x3F000000);
  Color get transparentCustom => Colors.transparent;
  Color get color7FFAD3 => const Color(0x7FFAD3D5);
  Color get color7F6844 => const Color(0x7F68442E);
  Color get color3F6844 => const Color(0x3F68442E);
  Color get color7FC080 => const Color(0x7FC08081);
  Color get grey200 => Colors.grey.shade200;
  Color get grey100 => Colors.grey.shade100;
}

final _appTheme = _AppColors();

// ---------------------------------------------------------------------------
// IMAGE CONSTANTS (inline)
// ---------------------------------------------------------------------------
class _Img {
  static const String _base = 'assets/imagens/pets/';
  static const String frame48 = '${_base}img_frame_48_white_a700.svg';
  static const String frame49 = '${_base}img_frame_49.svg';
  static const String frame50 = '${_base}img_frame_50.svg';
  static const String frame51 = '${_base}img_frame_51.svg';
  static const String image6 = '${_base}image_not_found.png';
  static const String images11 = '${_base}image_not_found.png';
  static const String vector = '${_base}image_not_found.png';
  static const String vectorGray800 = '${_base}image_not_found.png';
  static const String vethomePng5 = '${_base}img_vethome_png_5.png';
  static const String imageNotFound = '${_base}image_not_found.png';
}

// ---------------------------------------------------------------------------
// TEXT STYLES (inline)
// ---------------------------------------------------------------------------
class _TS {
  TextStyle get headline30BoldComfortaa => TextStyle(
    fontSize: 30.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Comfortaa',
    color: _appTheme.white_A700,
  );

  TextStyle get title22BoldComfortaa => TextStyle(
    fontSize: 22.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Comfortaa',
    color: _appTheme.gray_800,
  );

  TextStyle get title18BoldComfortaa => TextStyle(
    fontSize: 18.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Comfortaa',
    color: _appTheme.gray_800,
  );

  TextStyle get title16Comfortaa => TextStyle(
    fontSize: 16.fSize,
    fontFamily: 'Comfortaa',
    color: _appTheme.gray_800,
  );

  TextStyle get body14Comfortaa =>
      TextStyle(fontSize: 14.fSize, fontFamily: 'Comfortaa');

  TextStyle get bodyTextComfortaa =>
      TextStyle(fontFamily: 'Comfortaa', color: _appTheme.gray_800);
}

final _ts = _TS();

// ---------------------------------------------------------------------------
// IMAGE TYPE HELPERS (inline)
// ---------------------------------------------------------------------------
enum _ImageType { svg, png, network, networkSvg, file }

extension _ImageTypeExtension on String {
  _ImageType get imageType {
    if (startsWith('http') || startsWith('https')) {
      return endsWith('.svg') ? _ImageType.networkSvg : _ImageType.network;
    } else if (endsWith('.svg')) {
      return _ImageType.svg;
    } else if (startsWith('file://')) {
      return _ImageType.file;
    } else {
      return _ImageType.png;
    }
  }
}

// ---------------------------------------------------------------------------
// CUSTOM IMAGE VIEW (inline)
// ---------------------------------------------------------------------------
class _CustomImageView extends StatelessWidget {
  const _CustomImageView({
    this.imagePath,
    this.height,
    this.width,
    this.fit,
    this.radius,
    this.color,
    this.placeHolder,
    this.alignment,
    this.onTap,
    this.margin,
    this.border,
  });

  final String? imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final String? placeHolder;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? radius;
  final BoxBorder? border;

  String get _effectiveImagePath =>
      (imagePath == null || imagePath!.isEmpty) ? _Img.imageNotFound : imagePath!;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(alignment: alignment!, child: _buildWidget())
        : _buildWidget();
  }

  Widget _buildWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(onTap: onTap, child: _buildCircleImage()),
    );
  }

  Widget _buildCircleImage() {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: _buildImageWithBorder(),
      );
    }
    return _buildImageWithBorder();
  }

  Widget _buildImageWithBorder() {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(border: border, borderRadius: radius),
        child: _buildImageView(),
      );
    }
    return _buildImageView();
  }

  Widget _buildImageView() {
    switch (_effectiveImagePath.imageType) {
      case _ImageType.svg:
        return SizedBox(
          height: height,
          width: width,
          child: SvgPicture.asset(
            _effectiveImagePath,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
          ),
        );
      case _ImageType.file:
        return Image.file(
          File(_effectiveImagePath),
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
        );
      case _ImageType.networkSvg:
        return SvgPicture.network(
          _effectiveImagePath,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
        );
      case _ImageType.network:
        return CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: _effectiveImagePath,
          color: color,
          placeholder: (context, url) => SizedBox(
            height: 30,
            width: 30,
            child: LinearProgressIndicator(
              color: _appTheme.grey200,
              backgroundColor: _appTheme.grey100,
            ),
          ),
          errorWidget: (context, url, error) => Image.asset(
            placeHolder ?? _Img.imageNotFound,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
          ),
        );
      case _ImageType.png:
        return Image.asset(
          _effectiveImagePath,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// CUSTOM ICON BUTTON (inline)
// ---------------------------------------------------------------------------
class _CustomIconButton extends StatelessWidget {
  const _CustomIconButton({
    required this.imagePath,
    this.onTap,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.buttonSize,
    this.borderRadius,
  });

  final String imagePath;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? buttonSize;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final double resolvedSize = buttonSize ?? 66.h;
    final double resolvedRadius = borderRadius ?? 32.h;
    final Color resolvedBgColor = backgroundColor ?? _appTheme.red_100;
    final EdgeInsetsGeometry resolvedPadding = padding ?? EdgeInsets.all(8.h);

    return Container(
      margin: margin,
      child: Material(
        color: _appTheme.transparentCustom,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(resolvedRadius),
          child: Ink(
            width: resolvedSize,
            height: resolvedSize,
            decoration: BoxDecoration(
              color: resolvedBgColor,
              borderRadius: BorderRadius.circular(resolvedRadius),
              boxShadow: [
                BoxShadow(
                  color: _appTheme.black_900_3f,
                  offset: Offset(2.h, 2.h),
                  blurRadius: 2.h,
                ),
              ],
            ),
            child: Padding(
              padding: resolvedPadding,
              child: _CustomImageView(
                imagePath: imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CUSTOM FAB BUTTON (inline)
// ---------------------------------------------------------------------------
class _CustomFabButton extends StatelessWidget {
  const _CustomFabButton({
    required this.onPressed,
    this.imagePath,
    this.backgroundColor,
    this.buttonSize,
    this.borderRadius,
  });

  final VoidCallback onPressed;
  final String? imagePath;
  final Color? backgroundColor;
  final double? buttonSize;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final double resolvedSize = buttonSize ?? 66.h;
    final double resolvedBorderRadius = borderRadius ?? 32.h;
    final Color resolvedBackgroundColor = backgroundColor ?? _appTheme.red_100;

    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: resolvedBackgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(resolvedBorderRadius),
        ),
        child: imagePath != null
            ? _CustomImageView(
                imagePath: imagePath,
                height: resolvedSize * 0.55,
                width: resolvedSize * 0.55,
                fit: BoxFit.contain,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PERFIL PAGE (main screen)
// ---------------------------------------------------------------------------
class PerfilPage extends StatefulWidget {
  const PerfilPage({Key? key}) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String _profileName = "Liminha";
  String _dateOfBirth = "05 / 02 / 2007";
  String? _profileImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  void _showChangePhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _appTheme.red_100,
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
                Text("Mudar Foto de Perfil", style: _ts.title18BoldComfortaa),
                SizedBox(height: 20.h),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: _appTheme.gray_800),
                  title: Text("Câmera", style: _ts.title16Comfortaa),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: _appTheme.gray_800),
                  title: Text("Galeria", style: _ts.title16Comfortaa),
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
      SnackBar(content: Text(message), backgroundColor: _appTheme.red_300),
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
          backgroundColor: _appTheme.red_100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.h),
          ),
          title: Text("Mudar Nome de Perfil", style: _ts.title18BoldComfortaa),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              style: _ts.title16Comfortaa,
              decoration: InputDecoration(
                hintText: "Digite o novo nome",
                hintStyle: _ts.body14Comfortaa.copyWith(
                  color: const Color(0xFF68442E).withAlpha(128),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _appTheme.red_300),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _appTheme.gray_800),
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
              child: Text("Cancelar", style: _ts.bodyTextComfortaa),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _appTheme.red_300,
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
                style: _ts.bodyTextComfortaa.copyWith(
                  color: _appTheme.white_A700,
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
              primary: _appTheme.red_300,
              onPrimary: _appTheme.white_A700,
              onSurface: _appTheme.gray_800,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _appTheme.gray_800),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            _SizeUtils.setScreenSize(constraints, orientation);
            return Scaffold(
              backgroundColor: _appTheme.red_100,
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
                      child: _CustomFabButton(
                        onPressed: _showChangePhotoOptions,
                        imagePath: _Img.frame49,
                        backgroundColor: _appTheme.red_100,
                        buttonSize: 66.h,
                        borderRadius: 32.h,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
                color: _appTheme.red_300,
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
                    child: _CustomImageView(
                      imagePath: _Img.vethomePng5,
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
                      style: _ts.headline30BoldComfortaa.copyWith(
                        height: 34 / 30,
                      ),
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
        color: _appTheme.color7FFAD3,
        border: Border.all(color: _appTheme.red_300, width: 5.h),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.h),
          topRight: Radius.circular(30.h),
          bottomLeft: Radius.circular(100.h),
          bottomRight: Radius.circular(100.h),
        ),
        boxShadow: [
          BoxShadow(
            color: _appTheme.black_900_3f,
            offset: const Offset(2, 2),
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
            style: _ts.title22BoldComfortaa.copyWith(height: 25 / 22),
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
          border: Border.all(color: _appTheme.color7F6844, width: 3.h),
        ),
        child: ClipOval(
          child: _profileImagePath != null
              ? Image.file(
                  File(_profileImagePath!),
                  width: 164.h,
                  height: 164.h,
                  fit: BoxFit.cover,
                )
              : _CustomImageView(
                  imagePath: _Img.images11,
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
        _CustomImageView(imagePath: _Img.vector, height: 22.h, width: 18.h),
        SizedBox(width: 8.h),
        Text(
          _dateOfBirth,
          style: _ts.title18BoldComfortaa.copyWith(height: 21 / 18),
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
          color: _appTheme.color3F6844,
        ),
        _buildMenuItem(
          title: "Mudar Nome de Perfil",
          onTap: _showChangeNameDialog,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12.h, vertical: 16.h),
          height: 1.h,
          color: _appTheme.color3F6844,
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
              style: _ts.title18BoldComfortaa.copyWith(height: 21 / 18),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _CustomImageView(
                imagePath: _Img.vectorGray800,
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
        color: _appTheme.color7FC080,
        borderRadius: BorderRadius.circular(24.h),
        boxShadow: [
          BoxShadow(
            color: _appTheme.black_900_3f,
            offset: const Offset(2, 2),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          _CustomIconButton(
            imagePath: _Img.frame48,
            backgroundColor: _appTheme.red_100,
            padding: EdgeInsets.all(8.h),
            onTap: () {},
          ),
          _CustomIconButton(
            imagePath: _Img.frame51,
            backgroundColor: _appTheme.color7FC080,
            padding: EdgeInsets.all(18.h),
            margin: EdgeInsets.only(left: 22.h),
            onTap: () {},
          ),
          _CustomIconButton(
            imagePath: _Img.frame50,
            backgroundColor: _appTheme.red_100,
            padding: EdgeInsets.all(14.h),
            margin: EdgeInsets.only(left: 22.h),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBottomImage() {
    return _CustomImageView(
      imagePath: _Img.image6,
      width: double.infinity,
      height: 50.h,
      fit: BoxFit.cover,
    );
  }
}