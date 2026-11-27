import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/agendamento_repository.dart';
import 'package:flutter_vethome/data/pet_repository.dart';
import 'package:flutter_vethome/data/vacina_repository.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';

Agendamento _agendamento(
  String veterinario,
  DateTime inicio, {
  DateTime? fim,
}) => Agendamento(
  data: inicio,
  tipo: 'Consulta Geral',
  veterinario: veterinario,
  local: 'Clínica VetHome',
  status: StatusAgendamento.pendente,
  endDate: fim,
);

void main() {
  setUp(() {
    PetRepository.resetToDemo();
    AgendamentoRepository.clear();
    VacinaRepository.clear();
  });

  tearDown(() {
    AgendamentoRepository.clear();
    VacinaRepository.clear();
    PetRepository.resetToDemo();
  });

  group('AgendamentoRepository', () {
    final inicio = DateTime(2030, 1, 1, 10);

    test('conflita com o mesmo veterinário em outro pet', () {
      AgendamentoRepository.adicionar(
        'pet-demo-1',
        _agendamento('Dra. Ana', inicio),
      );
      expect(
        AgendamentoRepository.temConflito(
          petId: 'pet-demo-2',
          veterinarian: ' dra. ana ',
          start: DateTime(2030, 1, 1, 10, 30),
          end: DateTime(2030, 1, 1, 11, 30),
        ),
        isTrue,
      );
    });

    test('conflita com o mesmo pet e outro veterinário', () {
      AgendamentoRepository.adicionar(
        'pet-demo-1',
        _agendamento('Dra. Ana', inicio),
      );
      expect(
        AgendamentoRepository.temConflito(
          petId: 'pet-demo-1',
          veterinarian: 'Dr. João',
          start: DateTime(2030, 1, 1, 10, 30),
          end: DateTime(2030, 1, 1, 11, 30),
        ),
        isTrue,
      );
    });

    test('não conflita em horários separados nem com pet/vet diferentes', () {
      AgendamentoRepository.adicionar(
        'pet-demo-1',
        _agendamento('Dra. Ana', inicio),
      );
      expect(
        AgendamentoRepository.temConflito(
          petId: 'pet-demo-1',
          veterinarian: 'Dra. Ana',
          start: DateTime(2030, 1, 1, 11),
          end: DateTime(2030, 1, 1, 12),
        ),
        isFalse,
      );
      expect(
        AgendamentoRepository.temConflito(
          petId: 'pet-demo-2',
          veterinarian: 'Dr. João',
          start: DateTime(2030, 1, 1, 10),
          end: DateTime(2030, 1, 1, 11),
        ),
        isFalse,
      );
    });

    test('intervalo inválido conta como conflito', () {
      expect(
        AgendamentoRepository.temConflito(
          petId: 'pet-demo-1',
          veterinarian: 'Dra. Ana',
          start: inicio,
          end: inicio,
        ),
        isTrue,
      );
    });

    test('remover usa a identidade do agendamento', () {
      final salvo = _agendamento('Dra. Ana', inicio);
      final parecido = _agendamento('Dra. Ana', inicio);
      AgendamentoRepository.adicionar('pet-demo-1', salvo);

      expect(AgendamentoRepository.remover('pet-demo-1', parecido), isFalse);
      expect(AgendamentoRepository.remover('pet-demo-1', salvo), isTrue);
      expect(AgendamentoRepository.reais('pet-demo-1'), isEmpty);
    });

    test('listar junta demonstração e reais; pet inexistente fica vazio', () {
      final demo = AgendamentoRepository.listar('pet-demo-1').length;
      AgendamentoRepository.adicionar(
        'pet-demo-1',
        _agendamento('Dra. Ana', inicio),
      );
      expect(AgendamentoRepository.listar('pet-demo-1').length, demo + 1);
      expect(AgendamentoRepository.listar('nao-existe'), isEmpty);
      expect(
        () => AgendamentoRepository.adicionar(
          'nao-existe',
          _agendamento('Dra. Ana', inicio),
        ),
        throwsArgumentError,
      );
    });

    test('snapshot e restore preservam os agendamentos', () {
      final salvo = _agendamento('Dra. Ana', inicio);
      AgendamentoRepository.adicionar('pet-demo-1', salvo);
      final copia = AgendamentoRepository.snapshot();

      AgendamentoRepository.clear();
      expect(AgendamentoRepository.reais('pet-demo-1'), isEmpty);

      AgendamentoRepository.restore(copia);
      expect(AgendamentoRepository.reais('pet-demo-1').single, same(salvo));
    });

    test('VetRepository repassa para o AgendamentoRepository', () {
      AgendamentoRepository.adicionar(
        'pet-demo-1',
        _agendamento('Dra. Ana', inicio),
      );
      expect(VetRepository.realAppointments('pet-demo-1').length, 1);
      expect(
        VetRepository.agendamentos('pet-demo-1').length,
        AgendamentoRepository.listar('pet-demo-1').length,
      );
    });
  });

  group('VacinaRepository', () {
    final aplicada = DateTime(2024, 1, 1);

    test('usa demonstração até existir registro real', () {
      expect(VacinaRepository.usaDemonstracao('pet-demo-1'), isTrue);

      VacinaRepository.salvar(
        'pet-demo-1',
        Vacina(nome: ' V10 ', aplicada: aplicada),
      );

      expect(VacinaRepository.usaDemonstracao('pet-demo-1'), isFalse);
      final salvas = VacinaRepository.listar('pet-demo-1');
      expect(salvas.single.nome, 'V10');
      expect(salvas.single.id, isNotNull);
    });

    test('remover a última vacina não volta para a demonstração', () {
      VacinaRepository.salvar(
        'pet-demo-1',
        Vacina(nome: 'V10', aplicada: aplicada),
      );
      final id = VacinaRepository.reais('pet-demo-1').single.id!;

      VacinaRepository.remover('pet-demo-1', id);

      expect(VacinaRepository.reais('pet-demo-1'), isEmpty);
      expect(VacinaRepository.usaDemonstracao('pet-demo-1'), isFalse);
      expect(VacinaRepository.listar('pet-demo-1'), isEmpty);
    });

    test('rejeita ID de outro pet, nome vazio e data futura', () {
      VacinaRepository.salvar(
        'pet-demo-1',
        Vacina(nome: 'V10', aplicada: aplicada),
      );
      final id = VacinaRepository.reais('pet-demo-1').single.id!;

      expect(
        () => VacinaRepository.salvar(
          'pet-demo-2',
          Vacina(id: id, nome: 'V10', aplicada: aplicada),
        ),
        throwsFormatException,
      );
      expect(
        () => VacinaRepository.salvar(
          'pet-demo-1',
          Vacina(nome: '  ', aplicada: aplicada),
        ),
        throwsFormatException,
      );
      expect(
        () => VacinaRepository.salvar(
          'pet-demo-1',
          Vacina(nome: 'V10', aplicada: DateTime(2999)),
        ),
        throwsFormatException,
      );
      expect(
        () => VacinaRepository.salvar(
          'nao-existe',
          Vacina(nome: 'V10', aplicada: aplicada),
        ),
        throwsArgumentError,
      );
    });

    test('snapshot e restore preservam vacinas e a demonstração dispensada', () {
      VacinaRepository.salvar(
        'pet-demo-1',
        Vacina(nome: 'V10', aplicada: aplicada),
      );
      VacinaRepository.remover(
        'pet-demo-1',
        VacinaRepository.reais('pet-demo-1').single.id!,
      );
      VacinaRepository.salvar(
        'pet-demo-2',
        Vacina(nome: 'V4', aplicada: aplicada),
      );
      final vacinas = VacinaRepository.snapshot();
      final dispensadas = VacinaRepository.demoDispensadasSnapshot();

      VacinaRepository.clear();
      expect(VacinaRepository.usaDemonstracao('pet-demo-1'), isTrue);

      VacinaRepository.restore(vacinas, dispensadas);
      expect(VacinaRepository.usaDemonstracao('pet-demo-1'), isFalse);
      expect(VacinaRepository.reais('pet-demo-2').single.nome, 'V4');
    });

    test('VetRepository repassa para o VacinaRepository', () {
      expect(
        VetRepository.usesDemoVaccines('pet-demo-1'),
        VacinaRepository.usaDemonstracao('pet-demo-1'),
      );
      expect(
        VetRepository.vacinas('pet-demo-1').length,
        VacinaRepository.listar('pet-demo-1').length,
      );
    });
  });
}
