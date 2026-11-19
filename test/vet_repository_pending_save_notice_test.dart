import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/config_page.dart';

class _PendingNoticeStorage extends LocalStorage {
  final completion = Completer<void>();
  final savedNames = <String>[];

  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) {
    return completion.future.then((_) {
      savedNames.add(state.client.name);
    });
  }
}

void main() {
  testWidgets(
    'Configurações mostra o estado enquanto a gravação está pendente',
    (tester) async {
      final storage = _PendingNoticeStorage();
      await VetRepository.initialize(storage: storage);
      await tester.pumpWidget(const MaterialApp(home: ConfigScreen()));
      await tester.pump();

      VetRepository.updateClient(name: 'Salvando agora');
      await tester.pump();

      expect(storage.savedNames, isEmpty);
      expect(find.text('Salvando alterações no dispositivo…'), findsOneWidget);
      final button = find.widgetWithText(TextButton, 'Salvando…');
      expect(button, findsOneWidget);
      expect(tester.widget<TextButton>(button).onPressed, isNull);

      storage.completion.complete();
      await tester.pump();
      await tester.pump();

      expect(storage.savedNames, ['Salvando agora']);
      expect(VetRepository.savingChanges.value, isFalse);
      expect(VetRepository.unsavedChanges.value, isFalse);
      expect(find.text('Salvando alterações no dispositivo…'), findsNothing);
    },
  );
}
