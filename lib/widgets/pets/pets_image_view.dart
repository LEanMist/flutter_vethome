// lib/widgets/pets/pets_image_view.dart
// Widget de imagem reutilizável da PETS_PAGE — sem dependência de app_export.
//
// Dependências no pubspec.yaml:
//   flutter_svg: ^2.0.12
//   cached_network_image: ^3.4.1

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './pets_theme.dart';

extension _ImageTypeExtension on String {
  _ImageType get imageType {
    if (startsWith('http')) {
      return endsWith('.svg') ? _ImageType.networkSvg : _ImageType.network;
    } else if (endsWith('.svg')) {
      return _ImageType.svg;
    } else if (startsWith('file://')) {
      return _ImageType.file;
    }
    return _ImageType.png;
  }
}

enum _ImageType { svg, png, network, networkSvg, file }

/// Widget de imagem usado em toda a PETS_PAGE (asset, svg, rede ou arquivo).
class PetsImageView extends StatelessWidget {
  PetsImageView({
    Key? key,
    String? imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.margin,
    this.border,
  }) : imagePath = (imagePath == null || imagePath.isEmpty)
           ? PetsTheme.imgImageNotFound
           : imagePath,
       super(key: key);

  final String imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? radius;
  final BoxBorder? border;

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
      return ClipRRect(borderRadius: radius!, child: _buildImageWithBorder());
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

  /// Ícone de fallback. Corrigido: antes usava `size: width ?? 32`, o que
  /// quebrava (tamanho infinito) quando width era `double.infinity`.
  Widget _buildErrorIcon() {
    final double? w = width;
    final double iconSize = (w != null && w.isFinite) ? w : 32;
    return Icon(
      Icons.image_not_supported_outlined,
      size: iconSize,
      color: color ?? Colors.black38,
    );
  }

  Widget _buildImageView() {
    final ColorFilter? colorFilter =
        color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null;

    switch (imagePath.imageType) {
      case _ImageType.svg:
        return SvgPicture.asset(
          imagePath,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          colorFilter: colorFilter,
          errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
        );
      case _ImageType.networkSvg:
        return SvgPicture.network(
          imagePath,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          colorFilter: colorFilter,
          errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
        );
      case _ImageType.network:
        return CachedNetworkImage(
          imageUrl: imagePath,
          height: height,
          width: width,
          fit: fit,
          color: color,
          placeholder: (context, url) => SizedBox(
            height: 30,
            width: 30,
            child: LinearProgressIndicator(
              color: Colors.grey.shade200,
              backgroundColor: Colors.grey.shade100,
            ),
          ),
          errorWidget: (context, url, error) => Image.asset(
            PetsTheme.imgImageNotFound,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
          ),
        );
      case _ImageType.file:
        return Image.file(
          File(imagePath.replaceFirst('file://', '')),
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
          errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
        );
      case _ImageType.png:
        return Image.asset(
          imagePath,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
          errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
        );
    }
  }
}
