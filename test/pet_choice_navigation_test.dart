import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/screens/pets.dart' show EscolhaPetScreen;
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/pets/pet_card_widget.dart';

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

class _MemoryStorage extends LocalStorage {
  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Escolha de Pet seleciona o ID tocado e abre /servicos', (
    tester,
  ) async {
    await VetRepository.initialize(storage: _MemoryStorage());
    final previousId = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = previousId);

    final target = VetRepository.addPet(
      name: 'Pet do teste de navegação',
      species: 'Cachorro',
      sex: 'Macho',
      weightKg: 8,
      birthDate: DateTime(2021, 1, 1),
      breed: 'SRD',
    );
    VetRepository.selectedPetId = VetRepository.pets.first.id;
    expect(VetRepository.selectedPetId, isNot(target.id));

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: const EscolhaPetScreen(),
        routes: {
          '/servicos': (context) => Scaffold(
            body: Center(
              child: Text(
                'Rota de teste: ${ModalRoute.of(context)!.settings.name}',
              ),
            ),
          ),
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Rolar pets para baixo'));
    await tester.pumpAndSettle();

    final selectedCard = find.byWidgetPredicate(
      (widget) => widget is PetCardWidget && widget.pet.id == target.id,
    );
    expect(selectedCard, findsOneWidget);
    final name = tester.widget<Text>(
      find.descendant(of: selectedCard, matching: find.text(target.name)),
    );
    expect(name.style?.color, VetColors.brownOnRose);
    final figmaSurface = Color.alphaBlend(
      VetColors.roseOverlay50,
      const Color(0xFFECBEC0),
    );
    expect(
      _contrastRatio(name.style!.color!, figmaSurface),
      greaterThanOrEqualTo(4.5),
    );
    await tester.ensureVisible(selectedCard);
    await tester.tap(selectedCard);
    await tester.pumpAndSettle();

    expect(VetRepository.selectedPetId, target.id);
    expect(VetRepository.selectedPet?.id, target.id);
    expect(find.text('Rota de teste: /servicos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PetCardWidget mantém o texto branco fora da escolha de Pet', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PetCardWidget(pet: pet)),
      ),
    );

    final name = tester.widget<Text>(find.text(pet.name));
    expect(name.style?.color, Colors.white);
  });
}
