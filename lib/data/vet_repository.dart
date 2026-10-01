import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../widgets/pets/pets_theme.dart';

/// Dados de exemplo. Quando houver API, só este arquivo muda.
class VetRepository {
  VetRepository._();

  static final List<PetModel> pets = [
    PetModel(
      name: 'Fernando',
      imagePath: PetsTheme.imgCachorroegatoPng,
      description: perfil('Fernando').resumo,
    ),
    PetModel(
      name: 'Kelly',
      imagePath: PetsTheme.imgCachorroegatoPng36x32,
      description: perfil('Kelly').resumo,
    ),
    PetModel(
      name: 'Escarola',
      imagePath: PetsTheme.imgCachorroegatoPng,
      description: perfil('Escarola').resumo,
    ),
    PetModel(
      name: 'Eduardo',
      imagePath: PetsTheme.imgCachorroegatoPng36x32,
      description: perfil('Eduardo').resumo,
    ),
  ];

  static const PetProfile _padrao = PetProfile(
    especie: 'Cachorro',
    idadeAnos: 4,
    castrado: true,
    pesoKg: 12.5,
  );

  static const Map<String, PetProfile> _perfis = {
    'Kelly': PetProfile(
        especie: 'Gato', idadeAnos: 2, castrado: false, pesoKg: 4.2),
    'Escarola': PetProfile(
        especie: 'Cachorro', idadeAnos: 6, castrado: true, pesoKg: 18.0),
    'Eduardo': PetProfile(
        especie: 'Gato', idadeAnos: 1, castrado: false, pesoKg: 3.4),
  };

  static PetProfile perfil(String pet) => _perfis[pet] ?? _padrao;

  static DateTime get _hoje {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static List<Consulta> consultas(String pet) => [
        Consulta(
          data: _hoje.subtract(const Duration(days: 15)),
          tipo: 'Consulta Geral',
          veterinario: 'Dra. Ana Silva',
          descricao: 'Checkup completo. Tudo normal.',
        ),
        Consulta(
          data: _hoje.subtract(const Duration(days: 60)),
          tipo: 'Vermifugação',
          veterinario: 'Dr. João Mendes',
          descricao: 'Tratamento realizado com sucesso.',
        ),
        Consulta(
          data: _hoje.subtract(const Duration(days: 95)),
          tipo: 'Pesagem e avaliação',
          veterinario: 'Dra. Clara Lima',
          descricao: 'Peso estável e bem hidratado.',
        ),
      ];

  static List<Vacina> vacinas(String pet) => [
        Vacina(
          nome: 'V10',
          aplicada: _hoje.subtract(const Duration(days: 200)),
          proxima: _hoje.add(const Duration(days: 165)),
        ),
        Vacina(
          nome: 'Antirrábica',
          aplicada: _hoje.subtract(const Duration(days: 120)),
          proxima: _hoje.add(const Duration(days: 245)),
        ),
        Vacina(
          nome: 'Giardia',
          aplicada: _hoje.subtract(const Duration(days: 150)),
          proxima: _hoje.add(const Duration(days: 20)),
        ),
      ];

  static List<Despesa> despesas(String pet) {
    final n = DateTime.now();
    final inicio = DateTime(n.year, n.month, 1);
    final lista = [
      Despesa(
        data: inicio.add(const Duration(days: 2)),
        descricao: 'Consulta Veterinária',
        valor: 150.00,
        categoria: CategoriaDespesa.saude,
      ),
      Despesa(
        data: inicio.add(const Duration(days: 1)),
        descricao: 'Ração premium',
        valor: 95.60,
        categoria: CategoriaDespesa.alimentacao,
      ),
      Despesa(
        data: inicio,
        descricao: 'Antipulgas',
        valor: 68.90,
        categoria: CategoriaDespesa.saude,
      ),
      Despesa(
        data: DateTime(n.year, n.month - 1, 20),
        descricao: 'Banho e tosa',
        valor: 80.00,
        categoria: CategoriaDespesa.higiene,
      ),
    ];
    lista.sort((a, b) => b.data.compareTo(a.data));
    return lista;
  }

  static List<Agendamento> agendamentos(String pet) => [
        Agendamento(
          data: _hoje.add(const Duration(days: 5, hours: 14, minutes: 30)),
          tipo: 'Consulta Geral',
          veterinario: 'Dra. Ana Silva',
          local: 'Clínica VetHome',
          status: StatusAgendamento.confirmado,
        ),
        Agendamento(
          data: _hoje.add(const Duration(days: 20, hours: 10)),
          tipo: 'Vacinação',
          veterinario: 'Dr. João Mendes',
          local: 'Unidade Central',
          status: StatusAgendamento.pendente,
        ),
      ];
}
