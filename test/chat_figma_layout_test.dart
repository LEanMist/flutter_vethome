import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/chat_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

void main() {
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

    final composer = find.byKey(const ValueKey('chat-composer'));
    expect(tester.getSize(composer), const Size(366, 80));

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
          // Evita que o aviso ampliado esconda o controle de envio.
          expect(card.height, greaterThan(420));
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
