import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/addresses_page.dart';
import 'package:flutter_vethome/widgets.dart';

class _FailingAddressStorage extends LocalStorage {
  _FailingAddressStorage(this.address);

  final SavedAddress address;
  int saveCalls = 0;

  @override
  Future<LocalLoadResult> load() async => LocalLoadResult.valid(
    LocalState(
      client: ClientData(
        name: 'Cliente de teste',
        birthDate: DateTime(1990, 1, 1),
        address: address.summary,
        phone: '',
        email: '',
        gender: '',
        addresses: [address],
      ),
      pets: const [],
      appointments: const {},
    ),
  );

  @override
  Future<void> save(LocalState state) async {
    saveCalls++;
    throw StateError('falha de armazenamento simulada');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FailingAddressStorage storage;

  setUp(() async {
    storage = _FailingAddressStorage(
      const SavedAddress(
        id: 'home',
        street: 'Rua Antiga',
        number: '12',
        city: 'São Paulo',
        cep: '01001-000',
      ),
    );
    await VetRepository.initialize(storage: storage);
  });

  tearDown(() async {
    if (VetRepository.lastPersistenceError == null) {
      await VetRepository.flush();
    }
  });

  testWidgets('editar e excluir endereço avisam quando não foi salvo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const AddressesPage(),
        routes: {
          '/editar-endereco': (context) => AddressEditorPage(
            address:
                ModalRoute.of(context)?.settings.arguments as SavedAddress?,
          ),
        },
      ),
    );

    await tester.tap(find.bySemanticsLabel('Editar endereço Rua Antiga, 12'));
    await tester.pumpAndSettle();
    final streetField = find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == 'Logradouro',
      ),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(streetField, 'Rua Nova');
    final saveButton = find.bySemanticsLabel('Salvar endereço');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();

    expect(VetRepository.addresses.single.street, 'Rua Nova');
    expect(storage.saveCalls, 1);
    expect(
      find.text(
        'Dados atualizados nesta sessão. Não foi possível salvar localmente.',
      ),
      findsOneWidget,
    );

    ScaffoldMessenger.of(
      tester.element(find.byType(AddressesPage)),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Deletar endereço Rua Nova, 12'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Excluir'),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();

    expect(VetRepository.addresses, isEmpty);
    expect(storage.saveCalls, 2);
    expect(
      find.text(
        'Dados atualizados nesta sessão. Não foi possível salvar localmente.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
