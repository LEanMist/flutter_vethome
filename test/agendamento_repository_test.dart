import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';

void main() {
  test('confere data e hora, inclusive o instante exato', () {
    final agora = DateTime(2030, 5, 10, 15);
    expect(horarioJaPassou(agora, '14:00', agora: agora), isTrue);
    expect(horarioJaPassou(agora, '15:00', agora: agora), isTrue);
    expect(horarioJaPassou(agora, '16:00', agora: agora), isFalse);
    expect(
      horarioJaPassou(
        agora.add(const Duration(days: 1)),
        '12:00',
        agora: agora,
      ),
      isFalse,
    );
    expect(
      () => horarioJaPassou(agora, '25:00', agora: agora),
      throwsFormatException,
    );
  });

  test('rascunho rejeita horário de hoje que já começou', () {
    final rascunho = AgendamentoRascunho(
      usuarioId: 'usuario',
      petId: 'pet',
      data: DateTime.now(),
      horario: '00:00',
    );
    expect(
      rascunho.errors,
      contains('Este horário já passou. Escolha outro horário.'),
    );
  });

  test(
    'revalida horário ao salvar sem impedir atualizar reserva existente',
    () async {
      final data = DateTime.now().add(const Duration(days: 2));
      var agora = DateTime(data.year, data.month, data.day, 14, 59, 59);
      final repository = InMemoryAgendamentoRepository(agora: () => agora);
      final agendamento = _agendamento().copyWith(data: data, horario: '15:00');
      final salvo = await repository.save(agendamento);
      agora = DateTime(data.year, data.month, data.day, 15);
      await repository.save(
        salvo.copyWith(status: StatusAgendamento.cancelado),
      );
      await expectLater(
        repository.save(agendamento),
        throwsA(isA<HorarioPassadoException>()),
      );
      expect(await repository.findAll(), hasLength(1));
    },
  );

  test('serializa dados do agendamento para armazenamento', () {
    final agendamento = _agendamento();

    final restaurado = Agendamento.fromMap(agendamento.toMap());

    expect(restaurado.usuarioId, agendamento.usuarioId);
    expect(restaurado.petId, agendamento.petId);
    expect(restaurado.data, agendamento.data);
    expect(restaurado.horario, agendamento.horario);
    expect(restaurado.convenio, ConvenioAgendamento.petlove);
    expect(restaurado.status, StatusAgendamento.ativo);
    expect(restaurado.servicos.single.id, 'hemograma');
    expect(restaurado.servicos.single.categoria, CategoriaServico.exames);
  });

  test('converte status antigos para ativo ao restaurar dados', () {
    final dados = _agendamento().toMap();
    for (final status in ['solicitado', 'confirmado']) {
      dados['status'] = status;
      expect(Agendamento.fromMap(dados).status, StatusAgendamento.ativo);
    }
    dados['status'] = 'desconhecido';
    expect(() => Agendamento.fromMap(dados), throwsArgumentError);
  });

  test('conclui uma hora após o início e não altera cancelados', () async {
    final data = DateTime.now().add(const Duration(days: 2));
    var agora = DateTime(data.year, data.month, data.day, 12);
    final repository = InMemoryAgendamentoRepository(agora: () => agora);
    final ativo = await repository.save(
      _agendamento().copyWith(data: data, horario: '13:00'),
    );
    final cancelado = await repository.save(
      _agendamento().copyWith(
        data: data,
        horario: '15:00',
        status: StatusAgendamento.cancelado,
      ),
    );
    expect(ativo.status, StatusAgendamento.ativo);

    agora = DateTime(data.year, data.month, data.day, 13, 59, 59);
    expect(
      (await repository.findById(ativo.id!))!.status,
      StatusAgendamento.ativo,
    );
    agora = DateTime(data.year, data.month, data.day, 14);
    expect(
      (await repository.findByPetId('pet-1')).first.status,
      StatusAgendamento.concluido,
    );
    agora = DateTime(data.year, data.month, data.day + 1);
    expect(
      (await repository.findByUsuarioId('usuario-1')).first.status,
      StatusAgendamento.concluido,
    );
    expect(
      (await repository.findById(cancelado.id!))!.status,
      StatusAgendamento.cancelado,
    );

    agora = DateTime(data.year, data.month, data.day, 12);
    expect(
      (await repository.findById(ativo.id!))!.status,
      StatusAgendamento.concluido,
    );
    final atualizado = await repository.save(
      ativo.copyWith(descricao: 'Atualizado'),
    );
    expect(atualizado.status, StatusAgendamento.concluido);
  });

  test('conclui uma hora depois mesmo quando passa da meia-noite', () async {
    final data = DateTime.now().add(const Duration(days: 2));
    var agora = DateTime(data.year, data.month, data.day, 22);
    final repository = InMemoryAgendamentoRepository(agora: () => agora);
    final agendamento = await repository.save(
      _agendamento().copyWith(data: data, horario: '23:30'),
    );
    agora = DateTime(data.year, data.month, data.day + 1, 0, 29, 59);
    expect(
      (await repository.findById(agendamento.id!))!.status,
      StatusAgendamento.ativo,
    );
    agora = DateTime(data.year, data.month, data.day + 1, 0, 30);
    expect(
      (await repository.findById(agendamento.id!))!.status,
      StatusAgendamento.concluido,
    );
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
