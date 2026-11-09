import 'package:flutter/material.dart';

import '../../core/utils/vet_nav.dart';
import '../../models/pet_model.dart';
import '../../theme.dart';
import '../../theme/vet_colors.dart';
import '../pets/pets_theme.dart';
import 'vet_bottom_nav.dart';
import 'vet_header.dart';

/// Esqueleto único das telas internas: header + corpo rolável + barra inferior.
class VetPageScaffold extends StatelessWidget {
  const VetPageScaffold({
    super.key,
    required this.title,
    required this.children,
    this.pet,
    this.selectedIndex = 0,
    this.isTabRoot = false,
    this.showBack = true,
    this.headerBottom,
    this.footer,
    this.titleSize = 30,
    this.contentMaxWidth = VH.mobileContentMaxWidth,
    this.edgeToEdgeContentOnMobile = false,
  });

  final String title;
  final List<Widget> children;
  final PetModel? pet;
  final int selectedIndex;

  /// true quando a tela É a aba (ex.: Agenda); tocar na própria aba não faz nada.
  final bool isTabRoot;
  final bool showBack;
  final Widget? headerBottom;
  final Widget? footer;
  final double titleSize;
  final double contentMaxWidth;
  final bool edgeToEdgeContentOnMobile;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final contentPadding = VH.pagePaddingFor(width) * s;
    final horizontalContentPadding =
        edgeToEdgeContentOnMobile && width < VH.desktopBreakpoint
        ? 0.0
        : contentPadding;
    final headerTopPadding = media.padding.top > 14 * s
        ? media.padding.top
        : 14 * s;
    final headerHeight =
        (headerTopPadding +
                48 * s +
                22 * s +
                (headerBottom == null ? 0 : 52 * s))
            .clamp(125.0, double.infinity);
    final navigationHeight = 88 * s + media.viewPadding.bottom;
    final reservedFooterHeight = footer == null ? 0.0 : 140 * s;
    // In short viewports, scroll the whole page so fixed chrome cannot overflow.
    final shortViewportThreshold =
        headerHeight + navigationHeight + reservedFooterHeight;

    final header = VetHeader(
      title: title,
      titleSize: titleSize,
      showBack: showBack,
      bottom: headerBottom,
    );
    final pageContent = Center(
      child: ConstrainedBox(
        key: const ValueKey('vet-page-content'),
        constraints: BoxConstraints(
          maxWidth: contentMaxWidth.clamp(0, VH.desktopContentMaxWidth),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: 12 * s),
              children[i],
            ],
          ],
        ),
      ),
    );
    final footerContent = footer == null
        ? null
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8),
            child: footer!,
          );
    final navigation = VetBottomNav(
      selectedIndex: selectedIndex,
      onSelected: (i) => vetNavigate(
        context,
        i,
        selected: selectedIndex,
        isTabRoot: isTabRoot,
      ),
    );

    return Scaffold(
      backgroundColor: VetColors.pink,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useWholePageScroll =
              constraints.maxHeight < shortViewportThreshold;
          final shell = ConstrainedBox(
            key: const ValueKey('vet-page-shell'),
            constraints: const BoxConstraints(
              maxWidth: VH.desktopShellMaxWidth,
            ),
            child: Column(
              mainAxisSize: useWholePageScroll
                  ? MainAxisSize.min
                  : MainAxisSize.max,
              children: [
                header,
                if (useWholePageScroll)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalContentPadding,
                      contentPadding,
                      horizontalContentPadding,
                      contentPadding,
                    ),
                    child: pageContent,
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalContentPadding,
                        contentPadding,
                        horizontalContentPadding,
                        contentPadding,
                      ),
                      child: pageContent,
                    ),
                  ),
                ?footerContent,
                navigation,
              ],
            ),
          );

          if (useWholePageScroll) {
            return SingleChildScrollView(child: Center(child: shell));
          }
          return Center(child: shell);
        },
      ),
    );
  }
}

/// Alterna entre composições aprovadas para celular e desktop sem acoplar
/// regras de layout às páginas ou misturar os sistemas históricos VH e Vet.
class VetResponsiveLayout extends StatelessWidget {
  const VetResponsiveLayout({
    super.key,
    required this.mobile,
    required this.desktop,
    this.breakpoint = VH.desktopBreakpoint,
  });

  final Widget mobile;
  final Widget desktop;
  final double breakpoint;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      return width >= breakpoint ? desktop : mobile;
    },
  );
}
