import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/home_page.dart';
import 'package:flutter_vethome/routes/app_routes.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';

double _homeScaleFor(Size viewport) {
  final widthScale = (viewport.width / 390).clamp(0.0, 1.0).toDouble();
  return math.min(widthScale, math.max(0.8, viewport.height / 844));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a rota /home está registrada', () {
    expect(AppRoutes.routes.containsKey('/home'), isTrue);
  });

  for (final viewport in [
    const Size(390, 844),
    const Size(320, 640),
    const Size(1280, 800),
  ]) {
    testWidgets('HOME_PAGE_2 acompanha o frame em $viewport', (tester) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      final scale = _homeScaleFor(viewport);
      final frame = tester.getRect(
        find.byKey(const ValueKey('home-figma-frame')),
      );
      expect(frame.width, closeTo(390 * scale, .01));
      expect(frame.height, closeTo(844 * scale, .01));
      final systemUi = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      );
      expect(systemUi.value.systemNavigationBarColor, VetColors.pink);
      expect(systemUi.value.systemNavigationBarIconBrightness, Brightness.dark);
      expect(systemUi.value.systemNavigationBarContrastEnforced, isFalse);

      final illustration = tester.getRect(
        find.byKey(const ValueKey('home-walk-illustration')),
      );
      expect(illustration.left - frame.left, closeTo(-6 * scale, .01));
      expect(illustration.top - frame.top, closeTo(70 * scale, .01));
      expect(illustration.width, closeTo(400 * scale, .01));
      expect(illustration.height, closeTo(400 * scale, .01));

      final panel = tester.getRect(
        find.byKey(const ValueKey('home-welcome-panel')),
      );
      expect(panel.left - frame.left, closeTo(0, .01));
      expect(panel.top - frame.top, closeTo(415 * scale, .01));
      expect(panel.width, closeTo(390 * scale, .01));
      expect(panel.height, closeTo(429 * scale, .01));
      final panelContainer = tester.widget<Container>(
        find.byKey(const ValueKey('home-welcome-panel')),
      );
      final panelDecoration = panelContainer.decoration! as BoxDecoration;
      expect(panelDecoration.color, VetColors.pink);
      expect(
        panelDecoration.borderRadius,
        BorderRadius.only(
          topLeft: Radius.circular(50 * scale),
          topRight: Radius.circular(50 * scale),
          bottomLeft: Radius.circular(30 * scale),
          bottomRight: Radius.circular(30 * scale),
        ),
      );

      final title = tester.getRect(find.byKey(const ValueKey('home-title')));
      expect(title.top - frame.top, closeTo(458 * scale, 1));
      expect(title.left - frame.left, closeTo(-1 * scale, .01));
      final titleText = tester.widget<Text>(
        find.byKey(const ValueKey('home-title')),
      );
      expect(titleText.style?.color, VetColors.brown);
      expect(titleText.style?.fontFamily, VH.headingFontFamily);
      expect(titleText.style?.fontSize, 30 * scale);
      final titleSpan = titleText.textSpan! as TextSpan;
      final firstTitleWord = titleSpan.children![0] as TextSpan;
      final remainingTitle = titleSpan.children![1] as TextSpan;
      expect(firstTitleWord.text, 'Seja ');
      expect(firstTitleWord.style?.fontWeight, FontWeight.w600);
      expect(remainingTitle.text, 'Bem Vindo!');
      expect(remainingTitle.style?.fontWeight, FontWeight.bold);
      final subtitleFinder = find.text('Cuidando de quem\nte faz sorrir');
      expect(subtitleFinder, findsOneWidget);
      final subtitle = tester.widget<Text>(subtitleFinder);
      expect(
        tester.getRect(subtitleFinder).left - frame.left,
        closeTo(-1 * scale, .01),
      );
      expect(subtitle.style?.fontFamily, VH.headingFontFamily);
      expect(subtitle.style?.fontWeight, FontWeight.bold);
      expect(subtitle.style?.fontSize, 15 * scale);
      expect(subtitle.style?.height, isNull);

      final profile = tester.getRect(
        find.byKey(const ValueKey('home-profile-chip')),
      );
      expect(profile.left - frame.left, closeTo(242 * scale, .01));
      expect(profile.top - frame.top, closeTo(14 * scale, .01));
      expect(profile.width, closeTo(136 * scale, .01));
      expect(profile.height, closeTo(56 * scale, .01));
      final profileTarget = tester.getRect(
        find.byKey(const ValueKey('home-profile-target')),
      );
      expect(profileTarget.left, closeTo(profile.left, .01));
      expect(profileTarget.top, closeTo(profile.top, .01));
      expect(profileTarget.width, closeTo(136 * scale, .01));
      expect(profileTarget.height, closeTo(math.max(48, 56 * scale), .01));
      final profilePill = tester.widget<Container>(
        find.byKey(const ValueKey('home-profile-pill')),
      );
      final profileDecoration = profilePill.decoration! as BoxDecoration;
      expect(profileDecoration.color, VetColors.roseOverlay50);
      expect(
        profileDecoration.borderRadius,
        BorderRadius.circular(100 * scale),
      );
      expect(profileDecoration.boxShadow?.single.offset, const Offset(2, 2));
      final profileIcon = find.byKey(const ValueKey('home-profile-icon'));
      expect(tester.getSize(profileIcon).width, closeTo(28.6667 * scale, .01));
      final profileIconRect = tester.getRect(profileIcon);
      expect(profileIconRect.left - frame.left, closeTo(261 * scale, .01));
      expect(profileIconRect.top - frame.top, closeTo(27.6667 * scale, .01));
      final userName = tester.widget<Text>(
        find.byKey(const ValueKey('home-user-name')),
      );
      expect(userName.style?.fontFamily, VH.bodyFontFamily);
      expect(userName.style?.fontSize, 14 * scale);

      final play = tester.getRect(find.byKey(const ValueKey('home-open-pets')));
      expect(play.left - frame.left, closeTo(117 * scale, .01));
      expect(play.top - frame.top, closeTo(591 * scale, .01));
      expect(play.width, closeTo(155 * scale, .01));
      expect(play.height, closeTo(155 * scale, .01));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('HOME_PAGE_2 adapta título e espaçamento com texto a 200%', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    for (final viewport in [const Size(390, 844), const Size(320, 640)]) {
      tester.view.physicalSize = viewport;
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/pets': (_) => const Scaffold(body: Text('Pets destination')),
          },
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const HomePage(),
        ),
      );
      await tester.pumpAndSettle();

      final scale = _homeScaleFor(viewport);
      final titleFinder = find.byKey(const ValueKey('home-title'));
      final title = tester.widget<Text>(titleFinder);
      final titleRect = tester.getRect(titleFinder);
      final titlePainter = TextPainter(
        text: TextSpan(
          style: title.style,
          children: (title.textSpan! as TextSpan).children,
        ),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.linear(2),
      )..layout(maxWidth: 390 * scale);
      final subtitleRect = tester.getRect(
        find.byKey(const ValueKey('home-subtitle')),
      );
      final ringRect = tester.getRect(
        find.byKey(const ValueKey('home-dashed-ring')),
      );
      final frameRect = tester.getRect(
        find.byKey(const ValueKey('home-figma-frame')),
      );

      expect(title.maxLines, isNull, reason: '$viewport');
      expect(
        titlePainter.computeLineMetrics().length,
        greaterThan(1),
        reason:
            '$viewport: o título deve realmente quebrar em mais de uma linha',
      );
      titlePainter.dispose();
      expect(titleRect.height, greaterThan(40 * scale), reason: '$viewport');
      expect(
        subtitleRect.top,
        greaterThanOrEqualTo(titleRect.bottom + 8 * scale),
        reason: '$viewport',
      );
      expect(
        ringRect.top,
        greaterThanOrEqualTo(subtitleRect.bottom + 20 * scale),
        reason: '$viewport',
      );
      expect(
        frameRect.height,
        greaterThanOrEqualTo(ringRect.bottom + 10 * scale),
        reason: '$viewport',
      );

      final petsButton = find.byKey(const ValueKey('home-open-pets'));
      await tester.ensureVisible(petsButton);
      await tester.pumpAndSettle();
      final petsRect = tester.getRect(petsButton);
      expect(petsRect.top, greaterThanOrEqualTo(0), reason: '$viewport');
      expect(
        petsRect.bottom,
        lessThanOrEqualTo(viewport.height),
        reason: '$viewport',
      );
      await tester.tap(petsButton);
      await tester.pumpAndSettle();
      expect(
        find.text('Pets destination'),
        findsOneWidget,
        reason: '$viewport',
      );
      Navigator.of(tester.element(find.text('Pets destination'))).pop();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$viewport');
    }
  });

  testWidgets('HOME_PAGE_2: preserva o frame e rola em telas baixas', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    for (final viewport in [const Size(390, 844), const Size(320, 400)]) {
      tester.view.physicalSize = viewport;
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      final scale = _homeScaleFor(viewport);
      final frame = tester.getRect(
        find.byKey(const ValueKey('home-figma-frame')),
      );
      expect(frame.width, closeTo(390 * scale, .01));
      expect(frame.height, closeTo(844 * scale, .01));
      expect(frame.left, greaterThanOrEqualTo(0));
      expect(frame.right, lessThanOrEqualTo(viewport.width));

      final scrollView = find.byKey(const ValueKey('home-scroll-view'));
      if (viewport.height < frame.height) {
        expect(scrollView, findsOneWidget);
      } else {
        expect(scrollView, findsNothing);
      }

      final ring = tester.getRect(
        find.byKey(const ValueKey('home-dashed-ring')),
      );
      final play = tester.getRect(find.byKey(const ValueKey('home-open-pets')));
      expect(ring.width, closeTo(177 * scale, .01));
      expect(ring.height, closeTo(177 * scale, .01));
      expect(ring.center.dx, closeTo(play.center.dx, .01));
      expect(ring.center.dy, closeTo(play.center.dy, .01));

      for (final key in const [
        'home-title',
        'home-subtitle',
        'home-profile-chip',
        'home-dashed-ring',
        'home-open-pets',
      ]) {
        final rect = tester.getRect(find.byKey(ValueKey(key)));
        // O título e o subtítulo começam 1 px fora do frame no Figma.
        final allowedLeft = key == 'home-title' || key == 'home-subtitle'
            ? -scale
            : 0.0;
        expect(
          rect.left - frame.left,
          greaterThanOrEqualTo(allowedLeft - .01),
          reason: key,
        );
        expect(rect.top, greaterThanOrEqualTo(frame.top), reason: key);
        expect(rect.right, lessThanOrEqualTo(frame.right), reason: key);
        expect(rect.bottom, lessThanOrEqualTo(frame.bottom), reason: key);
      }
      if (viewport.height < frame.height) {
        final play = find.byKey(const ValueKey('home-open-pets'));
        expect(tester.getRect(play).bottom, greaterThan(viewport.height));
        await tester.drag(scrollView, const Offset(0, -1000));
        await tester.pumpAndSettle();
        expect(tester.getRect(play).bottom, lessThanOrEqualTo(viewport.height));
      }
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('HOME_PAGE_2: ações acessíveis em quatro viewports', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    try {
      for (final viewport in [
        const Size(320, 640),
        const Size(320, 400),
        const Size(390, 844),
        const Size(1280, 800),
      ]) {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          MaterialApp(
            home: const HomePage(),
            routes: {
              '/perfil': (_) => const Scaffold(body: Text('Destino Perfil')),
              '/pets': (_) => const Scaffold(body: Text('Destino Pets')),
            },
          ),
        );
        await tester.pumpAndSettle();

        final name = tester
            .widget<Text>(find.byKey(const ValueKey('home-user-name')))
            .data!;
        final profile = find.bySemanticsLabel('Perfil de $name');
        final scale = _homeScaleFor(viewport);
        final profileTarget = tester.getRect(
          find.byKey(const ValueKey('home-profile-target')),
        );
        final profileVisual = tester.getRect(
          find.byKey(const ValueKey('home-profile-chip')),
        );
        expect(profileTarget.width, closeTo(136 * scale, .01));
        expect(profileTarget.height, closeTo(math.max(48, 56 * scale), .01));
        expect(profileVisual.width, closeTo(136 * scale, .01));
        expect(profileVisual.height, closeTo(56 * scale, .01));
        expect(profileVisual.top, closeTo(profileTarget.top, .01));
        expect(profile, findsOneWidget, reason: 'perfil $viewport');
        final profileData = tester.getSemantics(profile).getSemanticsData();
        expect(profileData.flagsCollection.isButton, isTrue);
        expect(profileData.hasAction(SemanticsAction.tap), isTrue);

        final profileNode = tester.getSemantics(profile);
        profileNode.owner!.performAction(profileNode.id, SemanticsAction.tap);
        await tester.pumpAndSettle();
        expect(find.text('Destino Perfil'), findsOneWidget);
        Navigator.of(tester.element(find.text('Destino Perfil'))).pop();
        await tester.pumpAndSettle();

        await tester.ensureVisible(
          find.byKey(const ValueKey('home-open-pets')),
        );
        await tester.pumpAndSettle();
        final pets = find.bySemanticsLabel('Abrir área dos pets');
        expect(pets, findsOneWidget, reason: 'pets visível $viewport');
        final petsData = tester.getSemantics(pets).getSemanticsData();
        expect(petsData.flagsCollection.isButton, isTrue);
        expect(petsData.hasAction(SemanticsAction.tap), isTrue);
        final petsNode = tester.getSemantics(pets);
        petsNode.owner!.performAction(petsNode.id, SemanticsAction.tap);
        await tester.pumpAndSettle();
        expect(find.text('Destino Pets'), findsOneWidget);
        Navigator.of(tester.element(find.text('Destino Pets'))).pop();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    } finally {
      semantics.dispose();
    }
  });
  testWidgets(
    'HOME_PAGE_2 mantém o chip visual e toca a área expandida em 320x400',
    (tester) async {
      tester.view.physicalSize = const Size(320, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/perfil': (_) => const Scaffold(body: Text('Destino Perfil')),
          },
        ),
      );
      await tester.pumpAndSettle();

      final target = tester.getRect(
        find.byKey(const ValueKey('home-profile-target')),
      );
      final visual = tester.getRect(
        find.byKey(const ValueKey('home-profile-chip')),
      );
      expect(
        tester.getRect(find.byKey(const ValueKey('home-figma-frame'))).height,
        closeTo(844 * _homeScaleFor(const Size(320, 400)), .01),
      );
      expect(target.height, 48);
      expect(
        visual.height,
        closeTo(56 * _homeScaleFor(const Size(320, 400)), .01),
      );
      expect(visual.top, target.top);

      await tester.tapAt(Offset(target.center.dx, target.bottom - 1));
      await tester.pumpAndSettle();
      expect(find.text('Destino Perfil'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('HOME_PAGE_2 leva o chip ao Perfil e o play a Pets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: const HomePage(),
        routes: {
          '/perfil': (_) => const Scaffold(body: Text('Destino Perfil')),
          '/pets': (_) => const Scaffold(body: Text('Destino Pets')),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Abrir área dos pets'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('home-profile-target')));
    await tester.pumpAndSettle();
    expect(find.text('Destino Perfil'), findsOneWidget);

    Navigator.of(tester.element(find.text('Destino Perfil'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-open-pets')));
    await tester.pumpAndSettle();
    expect(find.text('Destino Pets'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
