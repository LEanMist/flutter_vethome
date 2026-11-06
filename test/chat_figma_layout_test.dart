import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/chat_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/widgets.dart';

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

    final sender = tester.widget<Text>(find.text('Gabriella Falcão').first);
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
}
