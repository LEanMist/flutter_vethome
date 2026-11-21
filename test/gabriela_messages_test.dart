import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/gabriela_demo_chat.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_messages_tab.dart';

void main() {
  testWidgets('mostra o estado vazio da lista local', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GabrielaMessagesTab(conversations: [])),
      ),
    );
    expect(find.text('Nenhuma conversa disponível.'), findsOneWidget);
    expect(find.textContaining('Demonstração local'), findsOneWidget);
  });

  testWidgets('conversas com o mesmo nome mantêm mensagens separadas', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GabrielaMessagesTab(
            conversations: [
              GabrielaConversation(id: 'demo-1', name: 'Alex', messages: []),
              GabrielaConversation(id: 'demo-2', name: 'Alex', messages: []),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Alex').first);
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma mensagem nesta conversa.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '  ');
    await tester.tap(find.byTooltip('Enviar mensagem'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma mensagem nesta conversa.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Primeira conversa');
    await tester.tap(find.byTooltip('Enviar mensagem'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Voltar para as conversas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alex').last);
    await tester.pumpAndSettle();
    expect(find.text('Primeira conversa'), findsNothing);
    expect(find.text('Nenhuma mensagem nesta conversa.'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('lista e conversa funcionam em tela curta', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 500);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GabrielaMessagesTab())),
    );
    expect(find.text('Chat'), findsOneWidget);
    expect(find.textContaining('Demonstração'), findsOneWidget);

    final contact = find.text('Rambo');
    await tester.scrollUntilVisible(contact, 100);
    await tester.tap(contact);
    await tester.pumpAndSettle();

    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    await tester.pumpAndSettle();
    final composer = find.byType(TextField);
    expect(composer.hitTestable(), findsOneWidget);
    await tester.enterText(composer, 'Mensagem de teste');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    expect(find.text('Mensagem de teste'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'rascunhos ficam em suas conversas e prévia mostra mensagem enviada',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GabrielaMessagesTab())),
      );

      await tester.tap(find.text('Nicolly'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Rascunho da Nicolly');
      await tester.tap(find.byTooltip('Voltar para as conversas'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Caio'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.enterText(find.byType(TextField), 'Mensagem para Caio');
      await tester.tap(find.byTooltip('Enviar mensagem'));
      await tester.pumpAndSettle();
      expect(find.text('Mensagem para Caio'), findsOneWidget);
      await tester.tap(find.byTooltip('Voltar para as conversas'));
      await tester.pumpAndSettle();
      expect(find.text('Mensagem para Caio'), findsOneWidget);

      await tester.tap(find.text('Nicolly'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Rascunho da Nicolly',
      );
    },
  );
}
