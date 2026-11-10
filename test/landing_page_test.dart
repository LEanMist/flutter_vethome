import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/landing_page.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  testWidgets('Landing: rótulos de serviços mantêm contraste legível', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1543, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LandingPage()));
    await tester.pumpAndSettle();

    for (final (asset, label) in const [
      ('landing-service-exams.jpg', 'Exames'),
      ('landing-service-vaccines.jpg', 'Vacinas'),
    ]) {
      final text = tester.widget<Text>(
        find.descendant(
          of: find.byKey(ValueKey('landing-service-label-$asset')),
          matching: find.text(label),
        ),
      );
      expect(text.style?.color, VetColors.calendarTextOnRose);
      expect(
        _contrastRatio(text.style!.color!, VetColors.rose),
        greaterThanOrEqualTo(4.5),
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Landing móvel: cartões de serviços mantêm contraste AA', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LandingPage()));
    await tester.pumpAndSettle();

    final cardSurface = Color.alphaBlend(
      VetColors.rose.withValues(alpha: .8),
      VetColors.pink,
    );
    for (final (asset, label) in const [
      ('landing-service-home.jpg', 'Atendimento a\ndomicílio'),
      ('landing-service-exams.jpg', 'Exames'),
      ('landing-service-vaccines.jpg', 'Vacinas'),
    ]) {
      final text = tester.widget<Text>(
        find.byKey(ValueKey('landing-service-label-$asset')),
      );
      expect(text.data, label);
      expect(text.style?.color, VetColors.calendarTextOnRose);
      expect(
        _contrastRatio(text.style!.color!, cardSurface),
        greaterThanOrEqualTo(4.5),
        reason: 'Rótulo $label no cartão móvel',
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Landing: seta de serviços mantém ícone e alvo de toque', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1543, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: const LandingPage(),
        routes: {'/login': (_) => const Scaffold(body: Text('Login aberto'))},
      ),
    );
    await tester.pumpAndSettle();

    final target = find.byKey(const ValueKey('landing-services-link'));
    expect(target, findsOneWidget);
    expect(tester.getRect(target), const Rect.fromLTWH(631, 387, 48, 48));

    final icon = find.descendant(
      of: target,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/imagens/figma/landing-services-arrow.png',
      ),
    );
    expect(icon, findsOneWidget);
    expect(tester.getRect(icon), const Rect.fromLTWH(639, 395, 32, 32));

    // Ativa a lateral do círculo ampliado, fora dos 32 px do ícone.
    await tester.tapAt(const Offset(635, 411));
    await tester.pumpAndSettle();
    expect(find.text('Login aberto'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Landing desktop oferece entradas claras e avaliações honestas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1543, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: const LandingPage(),
        routes: {
          '/sobre': (_) => const Scaffold(body: Text('Sobre aberto')),
          '/login': (_) => const Scaffold(body: Text('Demonstração aberta')),
        },
      ),
    );
    final initialError = tester.takeException();
    if (initialError is FlutterError) {
      fail('Erro na renderização inicial:\n${initialError.toStringDeep()}');
    }
    expect(initialError, isNull, reason: 'render inicial');

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Sobre nós'), findsOneWidget);
    expect(find.text('Atendimento a\ndomicílio'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);

    expect(find.bySemanticsLabel('Início'), findsOneWidget);
    expect(find.bySemanticsLabel('Sobre nós'), findsOneWidget);
    expect(find.bySemanticsLabel('Avaliações'), findsOneWidget);
    expect(find.bySemanticsLabel('Entrar na demonstração'), findsOneWidget);

    final homeLabel = tester.getRect(find.text('Home'));
    final aboutLabel = tester.getRect(find.text('Sobre nós'));
    final reviewLabel = tester.getRect(find.text('Review'));
    final explore = tester.getRect(
      find.widgetWithText(OutlinedButton, 'Explore'),
    );
    expect(homeLabel.left, closeTo(943, 1));
    expect(homeLabel.top, closeTo(61.83, 1));
    expect(aboutLabel.left, closeTo(1063, 1));
    expect(reviewLabel.left, closeTo(1217, 1));
    expect(explore.left, closeTo(1351, .01));
    expect(explore.top, closeTo(44, .01));
    expect(explore.width, closeTo(132, .01));
    expect(explore.height, closeTo(59, .01));

    final homeCard = tester.getRect(
      find.byKey(const ValueKey('landing-service-home')),
    );
    final examsCard = tester.getRect(
      find.byKey(const ValueKey('landing-service-exams')),
    );
    final vaccinesCard = tester.getRect(
      find.byKey(const ValueKey('landing-service-vaccines')),
    );
    expect(homeCard, const Rect.fromLTWH(60, 441, 176, 230));
    expect(examsCard, const Rect.fromLTWH(276, 441, 176, 230));
    expect(vaccinesCard, const Rect.fromLTWH(492, 441, 176, 230));
    expect(
      tester.getRect(
        find.byKey(
          const ValueKey('landing-service-image-landing-service-home.jpg'),
        ),
      ),
      const Rect.fromLTWH(70, 451, 156, 156),
    );
    expect(
      tester.getRect(
        find.byKey(
          const ValueKey('landing-service-label-landing-service-home.jpg'),
        ),
      ),
      const Rect.fromLTWH(70, 617, 157, 37),
    );
    expect(
      tester.getRect(
        find.byKey(
          const ValueKey('landing-service-image-landing-service-vaccines.jpg'),
        ),
      ),
      const Rect.fromLTWH(501, 451, 158, 158),
    );
    expect(
      tester
          .getTopLeft(
            find.byKey(
              const ValueKey(
                'landing-service-label-landing-service-vaccines.jpg',
              ),
            ),
          )
          .dy,
      closeTo(619, .5),
    );

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'abrir avaliações');
    expect(
      find.textContaining('não há avaliações disponíveis'),
      findsOneWidget,
    );

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'fechar avaliações');
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.text('Demonstração aberta'), findsOneWidget);
    final error = tester.takeException();
    if (error is FlutterError) {
      fail('A tela lançou erro após entrar:\n${error.toStringDeep()}');
    }
    expect(error, isNull, reason: 'entrar na demonstração');
  });

  testWidgets('Landing ampla refluí com texto do sistema a 200%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1543, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const LandingPage(),
        routes: {'/login': (_) => const Scaffold(body: Text('Login aberto'))},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('landing-figma-frame')), findsNothing);
    expect(find.byKey(const ValueKey('landing-mobile-title')), findsOneWidget);
    expect(tester.takeException(), isNull);

    final explore = find.bySemanticsLabel('Entrar na demonstração');
    await tester.ensureVisible(explore);
    expect(tester.getRect(explore).height, greaterThanOrEqualTo(48));
    await tester.tap(explore);
    await tester.pumpAndSettle();
    expect(find.text('Login aberto'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Landing tablet mantém texto dos serviços ampliado a 200%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const LandingPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('landing-mobile-title')), findsOneWidget);
    expect(find.byKey(const ValueKey('landing-tablet-title')), findsNothing);

    final serviceLabel = find.byKey(
      const ValueKey('landing-service-label-landing-service-home.jpg'),
    );
    await tester.ensureVisible(serviceLabel);
    final labelBounds = tester.getRect(serviceLabel);
    expect(labelBounds.height, greaterThan(37));
    expect(labelBounds.left, greaterThanOrEqualTo(0));
    expect(labelBounds.right, lessThanOrEqualTo(900));
    expect(tester.takeException(), isNull);
  });

  for (final viewport in const [Size(320, 640), Size(390, 844)]) {
    testWidgets(
      'Landing mobile reflow at ${viewport.width.toInt()} px keeps controls usable',
      (tester) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: const LandingPage(),
            routes: {
              '/sobre': (_) => const Scaffold(body: Text('Sobre aberto')),
              '/login': (_) => const Scaffold(body: Text('Login aberto')),
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byKey(const ValueKey('landing-figma-frame')), findsNothing);
        expect(
          find.byKey(const ValueKey('landing-mobile-title')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('landing-mobile-hero')),
          findsOneWidget,
        );

        for (final key in [
          'landing-service-home',
          'landing-service-exams',
          'landing-service-vaccines',
        ]) {
          final card = find.byKey(ValueKey(key));
          expect(card, findsOneWidget);
          final bounds = tester.getRect(card);
          expect(bounds.left, greaterThanOrEqualTo(0));
          expect(bounds.right, lessThanOrEqualTo(viewport.width));
        }

        final servicesLink = find.byKey(
          const ValueKey('landing-services-link'),
        );
        expect(tester.getSize(servicesLink), const Size(48, 48));
        for (final label in [
          'Início',
          'Sobre nós',
          'Avaliações',
          'Entrar na demonstração',
        ]) {
          final control = find.bySemanticsLabel(label);
          expect(control, findsOneWidget);
          expect(tester.getSize(control).height, greaterThanOrEqualTo(48));
        }

        final lastCard = find.byKey(const ValueKey('landing-service-vaccines'));
        await tester.ensureVisible(lastCard);
        await tester.pumpAndSettle();
        final lastCardBounds = tester.getRect(lastCard);
        expect(lastCardBounds.top, greaterThanOrEqualTo(0));
        expect(lastCardBounds.bottom, lessThanOrEqualTo(viewport.height));
        expect(tester.takeException(), isNull);

        final explore = find.text('Explore');
        await tester.ensureVisible(explore);
        await tester.pumpAndSettle();
        await tester.tap(explore);
        await tester.pumpAndSettle();
        expect(find.text('Login aberto'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final viewport in const [Size(900, 800), Size(1280, 800)]) {
    testWidgets(
      'Landing tablet/window layout at ${viewport.width.toInt()} px',
      (tester) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: const LandingPage(),
            routes: {
              '/sobre': (_) => const Scaffold(body: Text('Sobre aberto')),
              '/login': (_) => const Scaffold(body: Text('Login aberto')),
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byKey(const ValueKey('landing-figma-frame')), findsNothing);
        expect(
          find.byKey(const ValueKey('landing-tablet-title')),
          findsOneWidget,
        );
        expect(
          tester.getSize(find.byKey(const ValueKey('landing-services-link'))),
          const Size(48, 48),
        );
        for (final label in [
          'Início',
          'Sobre nós',
          'Avaliações',
          'Entrar na demonstração',
        ]) {
          expect(
            tester.getSize(find.bySemanticsLabel(label)).height,
            greaterThanOrEqualTo(48),
          );
        }
        for (final key in [
          'landing-service-home',
          'landing-service-exams',
          'landing-service-vaccines',
        ]) {
          expect(
            tester.getSize(find.byKey(ValueKey(key))),
            const Size(176, 230),
          );
        }

        final lastCard = find.byKey(const ValueKey('landing-service-vaccines'));
        await tester.ensureVisible(lastCard);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Landing mobile mantém destinos de navegação e seta', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> mountLanding() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          home: const LandingPage(),
          routes: {
            '/sobre': (_) => const Scaffold(body: Text('Sobre aberto')),
            '/login': (_) => const Scaffold(body: Text('Login aberto')),
          },
        ),
      );
      await tester.pumpAndSettle();
    }

    await mountLanding();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('landing-mobile-title')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await mountLanding();
    await tester.tap(find.text('Sobre nós'));
    await tester.pumpAndSettle();
    expect(find.text('Sobre aberto'), findsOneWidget);

    await mountLanding();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('não há avaliações disponíveis'),
      findsOneWidget,
    );
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    await mountLanding();
    final servicesLink = find.byKey(const ValueKey('landing-services-link'));
    await tester.ensureVisible(servicesLink);
    await tester.pumpAndSettle();
    await tester.tap(servicesLink);
    await tester.pumpAndSettle();
    expect(find.text('Login aberto'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
