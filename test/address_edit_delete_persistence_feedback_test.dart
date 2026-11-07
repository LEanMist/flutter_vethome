import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/addresses_page.dart';

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
        genderCustom: '',
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
  const address = SavedAddress(
    id: 'home',
    street: 'Rua Antiga',
    number: '12',
    city: 'São Paulo',
    cep: '01001-000',
  );
  late _FailingAddressStorage storage;

  setUp(() async {
    storage = _FailingAddressStorage(address);
    await VetRepository.initialize(storage: storage);
  });

  tearDown(() async {
    if (VetRepository.lastPersistenceError == null) {
      await VetRepository.flush();
    }
  });

  testWidgets('Excluir no formulário aguarda gravação e avisa na falha', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
    final deleteButton = find.bySemanticsLabel('Excluir endereço');
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
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
    expect(storage.saveCalls, 1);
    expect(
      find.text(
        'Dados atualizados nesta sessão. Não foi possível salvar localmente.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
