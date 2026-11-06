import 'dart:math' as math;
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/chat_page.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/routes/app_routes.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

double _contrastRatio(Color first, Color second) {
  final luminances = [_relativeLuminance(first), _relativeLuminance(second)]
    ..sort();
  return (luminances.last + 0.05) / (luminances.first + 0.05);
}

double _relativeLuminance(Color color) {
  double linearize(double value) {
    return value <= 0.04045
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * linearize(color.r) +
      0.7152 * linearize(color.g) +
      0.0722 * linearize(color.b);
}

void main() {
  testWidgets('a rota /chat abre a lista de conversas do Figma', (
    tester,
  ) async {
    final chatRoute = AppRoutes.routes['/chat']!;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: chatRoute)));
    await tester.pumpAndSettle();

    expect(find.byType(ChatListScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-list-card')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a aba Pets abre a lista a partir do Chat', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const ChatListScreen(),
        routes: {'/pets': AppRoutes.routes['/pets']!},
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Pets'));
    await tester.pumpAndSettle();

    expect(find.byType(PetsPage), findsOneWidget);
    expect(
      tester.widget<VetBottomNav>(find.byType(VetBottomNav)).selectedIndex,
      0,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('MESSAGE_PAGE limita o cartão em telas largas', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: ChatListScreen()));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey('chat-list-card'))).width,
      600,
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('chat-conversation-entry')))
          .width,
      328,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('MESSAGE_PAGE lista a conversa local e abre seu detalhe', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = FakeViewPadding.zero;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      MaterialApp(
        home: const ChatListScreen(),
        routes: {'/chat/conversa': (_) => const ChatScreen()},
      ),
    );
    await tester.pumpAndSettle();

    expect(AppRoutes.routes.containsKey('/chat/conversa'), isTrue);
    expect(
      tester.getRect(find.byType(VHHeader)),
      const Rect.fromLTWH(0, 0, 390, 125),
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('chat-list-card'))),
      const Rect.fromLTWH(12, 157, 366, 536),
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('chat-list-footer'))),
      const Rect.fromLTWH(12, 623, 366, 80),
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('chat-conversation-entry'))),
      const Rect.fromLTWH(31, 182, 328, 61),
    );
    expect(
      tester.widget<VetBottomNav>(find.byType(VetBottomNav)).showPetsTab,
      isTrue,
    );
    _expectFigmaChatNavigation(tester);
    expect(find.text('Nicolly'), findsNothing);
    expect(find.text('Então você envenou meu cachorro'), findsNothing);
    expect(find.text('15'), findsNothing);

    final rowBackground = Color.alphaBlend(
      VetColors.roseOverlay50,
      Color.alphaBlend(VetColors.roseOverlay25, VetColors.pink),
    );
    for (final value in [
      find.text('Gabriela Falcão'),
      find.text(VetRepository.chatMessages.last.text),
    ]) {
      final style = tester.widget<Text>(value).style!;
      expect(style.color, VetColors.brownOnRose);
      expect(
        _contrastRatio(style.color!, rowBackground),
        greaterThanOrEqualTo(4.5),
      );
    }

    final semantics = tester.ensureSemantics();
    try {
      final accessibleConversation = find.bySemanticsLabel(
        RegExp(r'Conversa com Gabriela Falcão'),
      );
      expect(accessibleConversation, findsOneWidget);
      expect(
        tester
            .getSemantics(accessibleConversation)
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      for (final label in [
        'Pets',
        'Perfil',
        'Conversa',
        'Agenda',
        'Configurações',
      ]) {
        expect(find.bySemanticsLabel(label), findsOneWidget);
      }
      expect(
        tester
                .getSemantics(find.bySemanticsLabel('Conversa'))
                .getSemanticsData()
                .flagsCollection
                .isSelected ==
            Tristate.isTrue,
        isTrue,
      );
    } finally {
      semantics.dispose();
    }

    await tester.tap(find.byKey(const ValueKey('chat-conversation-entry')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('chat-conversation-card')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('chat-locality-notice')), findsOneWidget);
    expect(
      tester.widget<VetBottomNav>(find.byType(VetBottomNav)).showPetsTab,
      isTrue,
    );
    _expectFigmaChatNavigation(tester);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('chat-list-card')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chat móvel segue as dimensões principais do Figma', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = FakeViewPadding.zero;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(const MaterialApp(home: ChatScreen()));
    await tester.pumpAndSettle();

    final header = find.byType(VHHeader);
    expect(tester.getTopLeft(header), Offset.zero);
    expect(tester.getSize(header), const Size(390, 125));

    final conversation = find.byKey(const ValueKey('chat-conversation-card'));
    expect(tester.getTopLeft(conversation), const Offset(12, 147));
    expect(tester.getSize(conversation), const Size(366, 556));
    expect(
      tester.widget<VetBottomNav>(find.byType(VetBottomNav)).showPetsTab,
      isTrue,
    );
    _expectFigmaChatNavigation(tester);

    final composer = find.byKey(const ValueKey('chat-composer'));
    expect(tester.getSize(composer), const Size(366, 80));
    expect(tester.getTopLeft(composer), const Offset(12, 623));
    final composerField = tester.widget<TextField>(find.byType(TextField));
    expect(composerField.decoration?.hintStyle?.color, VetColors.brownOnRose);
    final composerSurfaces = [
      Color.alphaBlend(
        VH.background.withValues(alpha: .5),
        VetColors.chatComposerBackground,
      ),
      Color.alphaBlend(
        VH.secondary.withValues(alpha: .375),
        VetColors.chatComposerBackground,
      ),
    ];
    for (final surface in composerSurfaces) {
      expect(
        _contrastRatio(VetColors.brownOnRose, surface),
        greaterThanOrEqualTo(4.5),
      );
    }
    expect(
      tester.getTopLeft(find.text('Gabriela Falcão').first).dy,
      closeTo(172, 1.5),
    );

    final bottomNav = find.byType(VetBottomNav);
    final navSurface = tester
        .widgetList<Container>(
          find.descendant(of: bottomNav, matching: find.byType(Container)),
        )
        .firstWhere(
          (item) =>
              item.decoration is inset_shadow.BoxDecoration &&
              item.margin == const EdgeInsets.fromLTRB(12, 6, 12, 50),
        );
    final navRect = tester.getRect(
      find.descendant(
        of: find.byWidget(navSurface),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration == navSurface.decoration,
        ),
      ),
    );
    expect(navRect.left, closeTo(12, 1));
    expect(navRect.top, closeTo(724, 1));
    expect(navRect.size, const Size(366, 70));

    final sender = tester.widget<Text>(find.text('Gabriela Falcão').first);
    expect(sender.style?.fontFamily, VH.headingFontFamily);
    expect(sender.style?.fontSize, 20);

    final message = tester.widget<Text>(
      find.text(VetRepository.chatMessages.first.text),
    );
    expect(message.style?.fontFamily, VH.headingFontFamily);
    expect(message.style?.fontSize, 10);
    expect(
      find.byIcon(Icons.done_all_rounded),
      findsNWidgets(VetRepository.chatMessages.length),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('MESSAGE_PAGE_2: balões dos dois remetentes usam rosa Figma', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: ChatScreen()));
    await tester.pumpAndSettle();

    final incoming = VetRepository.chatMessages.firstWhere(
      (message) => !message.fromClient,
    );
    final outgoing = VetRepository.chatMessages.firstWhere(
      (message) => message.fromClient,
    );

    Finder bubbleFor(String messageText) => find
        .ancestor(
          of: find.text(messageText).first,
          matching: find.byType(Container),
        )
        .first;

    final receivedBubble = bubbleFor(incoming.text);
    final sentBubble = bubbleFor(outgoing.text);
    for (final bubble in [receivedBubble, sentBubble]) {
      final decoration = tester.widget<Container>(bubble).decoration;
      expect(decoration, isA<BoxDecoration>());
      expect((decoration! as BoxDecoration).color, VetColors.roseOverlay50);
      expect(tester.getSize(bubble).width, closeTo(273, 0.1));
    }
    for (final text in [incoming.text, outgoing.text]) {
      expect(
        tester.widget<Text>(find.text(text)).style?.color,
        VetColors.chatMessageText,
      );
    }
    final cardBackground = Color.alphaBlend(VH.muted, VH.background);
    final bubbleBackground = Color.alphaBlend(
      VetColors.roseOverlay50,
      cardBackground,
    );
    expect(
      _contrastRatio(VetColors.chatMessageText, bubbleBackground),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      tester.getTopLeft(receivedBubble).dx,
      lessThan(tester.getTopLeft(sentBubble).dx),
    );
    expect(find.byKey(const ValueKey('chat-locality-notice')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final (viewport, scale) in const [
    (Size(320, 640), 1.0),
    (Size(320, 640), 1.5),
    (Size(320, 640), 2.0),
    (Size(390, 844), 1.5),
    (Size(390, 844), 2.0),
    (Size(1280, 800), 2.0),
  ]) {
    testWidgets(
      'Chat: campo de texto e aviso legíveis em $viewport a ${scale}x',
      (tester) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: const ChatScreen(),
          ),
        );
        await tester.pumpAndSettle();

        final card = tester.getRect(
          find.byKey(const ValueKey('chat-conversation-card')),
        );
        final notice = tester.getRect(
          find.byKey(const ValueKey('chat-locality-notice')),
        );
        final composer = tester.getRect(
          find.byKey(const ValueKey('chat-composer')),
        );
        expect(card.height, greaterThanOrEqualTo(420));
        expect(notice.bottom, lessThanOrEqualTo(composer.top));
        expect(composer.bottom, lessThanOrEqualTo(card.bottom + 0.1));

        final field = find.byType(TextField);
        expect(field, findsOneWidget);
        expect(find.byTooltip('Enviar mensagem'), findsOneWidget);
        final editable = find.descendant(
          of: field,
          matching: find.byType(EditableText),
        );
        expect(editable, findsOneWidget);

        RenderEditable? findRenderEditable(RenderObject root) {
          if (root is RenderEditable) return root;
          RenderEditable? found;
          root.visitChildren((child) {
            found ??= findRenderEditable(child);
          });
          return found;
        }

        final renderedEditor = findRenderEditable(
          tester.renderObject(editable),
        );
        expect(renderedEditor, isNotNull);
        expect(
          renderedEditor!.size.height,
          greaterThanOrEqualTo(renderedEditor.preferredLineHeight - 1),
        );

        if (viewport == const Size(320, 640) && scale == 2.0) {
          // O aviso acima do cartão não reduz a área do compositor.
          expect(card.height, greaterThanOrEqualTo(420));
          await tester.ensureVisible(find.byTooltip('Enviar mensagem'));
          await tester.pumpAndSettle();
          expect(
            tester.getRect(find.byTooltip('Enviar mensagem')).top,
            greaterThanOrEqualTo(0),
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Chat: mensagem vazia não envia, Enter envia só à sessão', (
    tester,
  ) async {
    final before = List.of(VetRepository.chatMessages);
    addTearDown(() {
      VetRepository.chatMessages
        ..clear()
        ..addAll(before);
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: ChatScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.byTooltip('Enviar mensagem'));
    await tester.pump();
    expect(VetRepository.chatMessages, hasLength(before.length));

    await tester.enterText(find.byType(TextField), '  Mensagem por Enter  ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(VetRepository.chatMessages, hasLength(before.length + 1));
    expect(VetRepository.chatMessages.last.text, 'Mensagem por Enter');
    expect(VetRepository.chatMessages.last.fromClient, isTrue);
    expect(find.text('Mensagem por Enter'), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-locality-notice')), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
    );
    expect(tester.takeException(), isNull);
  });
}

void _expectFigmaChatNavigation(WidgetTester tester) {
  final nav = find.byType(VetBottomNav);
  for (final (index, label) in const [
    (0, 'Pets'),
    (1, 'Perfil'),
    (2, 'Conversa'),
    (3, 'Agenda'),
    (4, 'Configurações'),
  ]) {
    final destination = find.descendant(
      of: nav,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label == label,
      ),
    );
    expect(destination, findsOneWidget);
    final rect = tester.getRect(destination);
    expect(rect.left, closeTo(30 + index * 70, 0.5));
    expect(rect.top, closeTo(734, 0.5));
    expect(rect.size, const Size(50, 50));
  }
}
