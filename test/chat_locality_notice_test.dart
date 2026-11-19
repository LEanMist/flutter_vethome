import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/chat_page.dart';

void main() {
  const notice =
      'Conversa de demonstração local. As mensagens digitadas aparecem somente '
      'nesta sessão e não são enviadas à veterinária.';
  const visibleNotice =
      'Demonstração local: mensagens não são enviadas à veterinária.';

  testWidgets('aviso local fica visível, fora da lista, e acessível', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: ChatScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Whatsapp'), findsOneWidget);
    final banner = find.byKey(const ValueKey('chat-locality-notice'));
    expect(banner, findsOneWidget);
    expect(find.text(visibleNotice), findsOneWidget);
    expect(find.bySemanticsLabel(notice), findsOneWidget);
    expect(
      find.ancestor(of: banner, matching: find.byType(ListView)),
      findsNothing,
    );
    final card = tester.getRect(
      find.byKey(const ValueKey('chat-conversation-card')),
    );
    expect(tester.getRect(banner).bottom, lessThanOrEqualTo(card.top));
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView).first, const Offset(0, -160));
    await tester.pump();
    expect(banner, findsOneWidget);
    expect(find.text(visibleNotice), findsOneWidget);

    tester.view.physicalSize = const Size(1200, 900);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('chat-desktop-layout')), findsOneWidget);
    expect(banner, findsOneWidget);
    expect(find.bySemanticsLabel(notice), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('mensagem digitada é adicionada apenas à conversa local', (
    tester,
  ) async {
    final previous = List.of(VetRepository.chatMessages);
    addTearDown(() {
      VetRepository.chatMessages
        ..clear()
        ..addAll(previous);
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: ChatScreen()));
    final initialCount = VetRepository.chatMessages.length;
    const typed = 'Mensagem somente local de teste';

    await tester.enterText(find.byType(TextField), typed);
    await tester.ensureVisible(find.byTooltip('Enviar mensagem'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Enviar mensagem'));
    await tester.pump();

    expect(VetRepository.chatMessages.length, initialCount + 1);
    expect(VetRepository.chatMessages.last.text, typed);
    expect(VetRepository.chatMessages.last.fromClient, isTrue);
    expect(find.text(typed), findsOneWidget);
    expect(find.text(visibleNotice), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    expect(tester.takeException(), isNull);
  });
}
