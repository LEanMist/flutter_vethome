import '../core/utils/formatters.dart';
import '../core/utils/pet_images.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../service/pet_service.dart';
import 'session.dart';

/// Pets do cliente logado: lista em memória + pet selecionado.
/// Os dados vêm do backend via [PetService]. É a fonte única de pets; o
/// [VetRepository] apenas repassa para cá e cuida da persistência local.
class PetRepository {
  PetRepository._();

  /// A seleção é guardada por ID (índices mudam quando a lista muda).
  static String? selectedPetId;

  /// Começa com os pets de exemplo (modo demonstração, sem cliente logado).
  static final List<PetModel> pets = demoPets();

  /// CPF do cliente dono da lista atual (para nunca mostrar pets de outro cliente).
  static String? _cpfDono;

  static PetModel? petById(String id) =>
      pets.where((pet) => pet.id == id).firstOrNull;

  static PetModel? get selectedPet =>
      (selectedPetId == null ? null : petById(selectedPetId!)) ??
      pets.firstOrNull;

  // Compatibilidade com as telas antigas; a seleção é armazenada por ID.
  static int get selectedPetIndex =>
      pets.indexWhere((pet) => pet.id == selectedPet?.id);

  static set selectedPetIndex(int index) {
    selectedPetId = index >= 0 && index < pets.length ? pets[index].id : null;
  }

  /// Volta para os pets de exemplo e limpa a seleção.
  static void resetToDemo() {
    selectedPetId = null;
    pets
      ..clear()
      ..addAll(demoPets());
  }

  static const PetProfile _perfilPadrao = PetProfile(
    especie: 'Cachorro',
    idadeAnos: 4,
    castrado: true,
    pesoKg: 12.5,
  );

  /// Resumo do pet usado nas telas de saúde/agenda.
  static PetProfile perfil(String petId) {
    final model = petById(petId);
    if (model == null) return _perfilPadrao;
    final age = model.birthDate == null
        ? model.ageYears ?? _perfilPadrao.idadeAnos
        : ageInYears(model.birthDate!, DateTime.now());
    return PetProfile(
      especie: model.species ?? _perfilPadrao.especie,
      idadeAnos: age,
      castrado: model.neutered,
      pesoKg: model.weightKg,
    );
  }

  static PetModel get firstPet => pets.isNotEmpty
      ? pets.first
      : PetModel(
          name: 'Pet',
          imagePath: 'assets/imagens/pets/img_cachorroegato_png.png',
          description: 'Pet sem cadastro',
        );

  /// Pets de exemplo do modo demonstração (sem cliente logado).
  static List<PetModel> demoPets() => [
    PetModel(
      id: 'pet-demo-1',
      name: 'Fernando',
      imagePath: PetImages.dog,
      description: _petSummary('Cachorro', 14, true),
      species: 'Cachorro',
      sex: 'M',
      weightKg: 24,
      birthDate: DateTime(2012, 3, 23),
      breed: 'Lulu-da-Pomerânia',
      neutered: true,
    ),
    PetModel(
      id: 'pet-demo-2',
      name: 'Kelly',
      imagePath: PetImages.cat,
      description: _petSummary('Gato', 2, false),
      species: 'Gato',
      sex: 'Fêmea',
      weightKg: 4.2,
      breed: 'Sem raça definida',
      neutered: false,
      ageYears: 2,
    ),
    PetModel(
      id: 'pet-demo-3',
      name: 'Escarola',
      imagePath: PetImages.dog,
      description: _petSummary('Cachorro', 6, true),
      species: 'Cachorro',
      sex: 'Fêmea',
      weightKg: 18,
      breed: 'Sem raça definida',
      neutered: true,
      ageYears: 6,
    ),
    PetModel(
      id: 'pet-demo-4',
      name: 'Eduardido',
      imagePath: PetImages.cat,
      description: _petSummary('Gato', 1, false),
      species: 'Gato',
      sex: 'Macho',
      weightKg: 3.4,
      breed: 'Sem raça definida',
      neutered: false,
      ageYears: 1,
    ),
  ];

  static String _petSummary(String species, int age, bool neutered) {
    return '$species • $age ${age == 1 ? 'ano' : 'anos'} • '
        '${neutered ? 'Castrado' : 'Não castrado'}';
  }

  /// Carrega do backend os pets do cliente logado.
  /// Sem cliente logado, mantém os pets de exemplo. Erros de rede/servidor são lançados.
  static Future<void> carregarPets({String? cpfCliente}) async {
    final cpf = (cpfCliente ?? Session.clientCpf).trim();
    if (cpf.isEmpty) {
      if (pets.isEmpty) pets.addAll(demoPets());
      return;
    }

    if (_cpfDono != cpf) {
      // Outro cliente: descarta a lista anterior antes de qualquer chamada de rede.
      pets.clear();
      selectedPetId = null;
      _cpfDono = cpf;
    }

    final petsDoBanco = await PetService.listarPets(cpfCliente: cpf);
    pets
      ..clear()
      ..addAll(petsDoBanco);
    if (selectedPetId != null && !pets.any((pet) => pet.id == selectedPetId)) {
      selectedPetId = pets.firstOrNull?.id;
    }
  }

  static bool petNameExists(String name, {String? except}) => pets.any(
    (pet) =>
        pet.name.toLowerCase() == name.trim().toLowerCase() &&
        pet.name.toLowerCase() != except?.toLowerCase(),
  );

  // ATENÇÃO: por enquanto só altera a lista local (não chama PUT /pet).
  static void updatePet(PetModel previous, PetModel updated) {
    final index = pets.indexOf(previous);
    if (index < 0) return;
    pets[index] = updated;
  }

  // ATENÇÃO: por enquanto só altera a lista local (não chama DELETE /pet/{id}).
  static void removePet(PetModel pet) {
    pets.removeWhere((item) => item.id == pet.id);
    if (selectedPetId == pet.id) selectedPetId = pets.firstOrNull?.id;
  }
}
