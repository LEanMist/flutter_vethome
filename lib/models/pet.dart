enum PetType { cachorro, gato, outro }

enum PetGenero { macho, femea }

class Pet {
  Pet({
    this.id,
    required this.tipo,
    required this.nome,
    required this.genero,
    required this.peso,
    required this.dataNascimento,
    required this.raca,
  });

  final String? id;
  final PetType tipo;
  final String nome;
  final PetGenero genero;
  final double peso;
  final DateTime dataNascimento;
  final String raca;

  List<String> get errors {
    final errors = <String>[];

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
    PetType? tipo,
    String? nome,
    PetGenero? genero,
    double? peso,
    DateTime? dataNascimento,
    String? raca,
  }) {
    return Pet(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      nome: nome ?? this.nome,
      genero: genero ?? this.genero,
      peso: peso ?? this.peso,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      raca: raca ?? this.raca,
    );
  }
}
