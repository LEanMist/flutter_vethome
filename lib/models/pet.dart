enum PetType { cachorro, gato, outro }

enum PetGenero { macho, femea }

class Pet {
  Pet({
    this.id,
    this.fotoPerfilPath,
    required this.usuarioId,
    required this.tipo,
    required this.nome,
    required this.genero,
    required this.peso,
    required this.dataNascimento,
    required this.raca,
  });

  final String? id;
  final String? fotoPerfilPath;
  final String usuarioId;
  final PetType tipo;
  final String nome;
  final PetGenero genero;
  final double peso;
  final DateTime dataNascimento;
  final String raca;

  List<String> get errors {
    final errors = <String>[];

    if (usuarioId.trim().isEmpty) {
      errors.add('O pet precisa estar associado a um usuário.');
    }
    if (tipo == PetType.outro) {
      errors.add('Selecione um tipo de animal válido.');
    }
    if (nome.trim().isEmpty) {
      errors.add('Nome do animal é obrigatório.');
    }
    if (peso <= 0) {
      errors.add('Peso deve ser maior que zero.');
    }
    if (dataNascimento.isAfter(DateTime.now())) {
      errors.add('Data de nascimento não pode ser futura.');
    }
    if (raca.trim().isEmpty) {
      errors.add('Raça é obrigatória.');
    }

    return errors;
  }

  Pet copyWith({
    String? id,
    String? fotoPerfilPath,
    PetType? tipo,
    String? nome,
    PetGenero? genero,
    double? peso,
    DateTime? dataNascimento,
    String? raca,
  }) {
    return Pet(
      id: id ?? this.id,
      fotoPerfilPath: fotoPerfilPath ?? this.fotoPerfilPath,
      usuarioId: usuarioId,
      tipo: tipo ?? this.tipo,
      nome: nome ?? this.nome,
      genero: genero ?? this.genero,
      peso: peso ?? this.peso,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      raca: raca ?? this.raca,
    );
  }
}
