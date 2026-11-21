import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';

void main() {
  test('serializa dados do agendamento para armazenamento', () {
    final agendamento = _agendamento();

    final restaurado = Agendamento.fromMap(agendamento.toMap());

    expect(restaurado.usuarioId, agendamento.usuarioId);
    expect(restaurado.petId, agendamento.petId);
    expect(restaurado.data, agendamento.data);
    expect(restaurado.horario, agendamento.horario);
    expect(restaurado.convenio, ConvenioAgendamento.petlove);
    expect(restaurado.status, StatusAgendamento.solicitado);
    expect(restaurado.servicos.single.id, 'hemograma');
    expect(restaurado.servicos.single.categoria, CategoriaServico.exames);
  });

  test('armazena e consulta agendamentos por usuario e pet', () async {
    final repository = InMemoryAgendamentoRepository();
    final salvo = await repository.save(_agendamento());

    expect(salvo.id, isNotEmpty);
    expect(await repository.findById(salvo.id!), salvo);
    expect(await repository.findByUsuarioId('usuario-1'), [salvo]);
    expect(await repository.findByPetId('pet-1'), [salvo]);
    expect(await repository.findAll(), [salvo]);

    await repository.delete(salvo.id!);
    expect(await repository.findById(salvo.id!), isNull);
  });

  test('rejeita agendamento sem servico selecionado', () async {
    final repository = InMemoryAgendamentoRepository();

    await expectLater(
      repository.save(_agendamento(servicos: const [])),
      throwsArgumentError,
    );
  });

  test(
    'bloqueia horário ocupado por outro usuário e libera após cancelamento',
    () async {
      final repository = InMemoryAgendamentoRepository();
      final primeiro = await repository.save(_agendamento());
      final outro = _agendamento().copyWith(
        usuarioId: 'usuario-2',
        petId: 'pet-2',
      );

      expect(await repository.horariosOcupados(primeiro.data), {'13:00'});
      expect(
        await repository.horariosOcupados(
          primeiro.data.add(const Duration(days: 1)),
        ),
        isEmpty,
      );
      await expectLater(
        repository.save(outro),
        throwsA(isA<HorarioOcupadoException>()),
      );
      await repository.save(
        primeiro.copyWith(status: StatusAgendamento.cancelado),
      );
      expect(await repository.horariosOcupados(primeiro.data), isEmpty);
      final salvo = await repository.save(outro);
      await repository.save(salvo.copyWith(descricao: 'Atualizado'));
      expect(await repository.horariosOcupados(primeiro.data), {'13:00'});
    },
  );
}

Agendamento _agendamento({List<ServicoAgendamento>? servicos}) {
  final amanha = DateTime.now().add(const Duration(days: 1));
  return Agendamento(
    usuarioId: 'usuario-1',
    petId: 'pet-1',
    data: DateTime(amanha.year, amanha.month, amanha.day),
    horario: '13:00',
    servicos:
        servicos ??
        const [
          ServicoAgendamento(
            id: 'hemograma',
            categoria: CategoriaServico.exames,
            nome: 'Hemograma',
          ),
        ],
    convenio: ConvenioAgendamento.petlove,
  );
}
