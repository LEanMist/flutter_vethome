import '../models/pet_model.dart';
import '../service/pet_service.dart';
import 'session.dart';

/// Pets do cliente logado: lista em memória + pet selecionado.
/// Os dados vêm do backend via [PetService].
class PetRepository {
  PetRepository._();

  static int selectedPetIndex = 0;

  /// Começa com um pet de exemplo (modo demonstração, sem cliente logado).
  static final List<PetModel> pets = _defaultPets();

  /// CPF do cliente dono da lista atual (para nunca mostrar pets de outro cliente).
  static String? _cpfDono;

  static PetModel get firstPet => pets.isNotEmpty
      ? pets.first
      : PetModel(
          name: 'Pet',
          imagePath: 'assets/imagens/pets/img_cachorroegato_png.png',
          description: 'Pet sem cadastro',
        );

  static List<PetModel> _defaultPets() {
    return [
      PetModel(
        name: 'Fernando',
        imagePath: 'assets/imagens/figma/cachorroegatopng-3.png',
        description: 'Cachorro • 5 anos • Macho',
        species: 'Cachorro',
        sex: 'Macho',
        weightKg: 24.0,
        birthDate: DateTime(2019, 3, 23),
        breed: 'Lulu-da-Pomerânia',
        neutered: true,
      ),
    ];
  }

  /// Carrega do backend os pets do cliente logado.
  /// Sem cliente logado, mantém os pets de exemplo. Erros de rede/servidor são lançados.
  static Future<void> carregarPets({String? cpfCliente}) async {
    final cpf = (cpfCliente ?? Session.clientCpf).trim();
    if (cpf.isEmpty) {
      if (pets.isEmpty) pets.addAll(_defaultPets());
      return;
    }

    if (_cpfDono != cpf) {
      // Outro cliente: descarta a lista anterior antes de qualquer chamada de rede.
      pets.clear();
      selectedPetIndex = 0;
      _cpfDono = cpf;
    }

    final petsDoBanco = await PetService.listarPets(cpfCliente: cpf);
    pets
      ..clear()
      ..addAll(petsDoBanco);
    selectedPetIndex = pets.isEmpty
        ? 0
        : selectedPetIndex.clamp(0, pets.length - 1).toInt();
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
    pets.remove(pet);
    selectedPetIndex = pets.isEmpty
        ? 0
        : selectedPetIndex.clamp(0, pets.length - 1).toInt();
  }
}
