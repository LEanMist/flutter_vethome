import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/configuracoes_page.dart';
import 'package:flutter_vethome/pages/historico_agendamento_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';

void main() {
  testWidgets(
    'mostra somente os agendamentos do usuário sem permitir alterações',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
      final usuario = usuarios.findAll().single;
      final pets = InMemoryPetRepository();
      pets.save(
        Pet(
          id: 'pet-1',
          usuarioId: usuario.id!,
          tipo: PetType.cachorro,
          nome: 'Luna',
          genero: PetGenero.femea,
          peso: 4,
          dataNascimento: DateTime(2020),
          raca: 'Sem raça definida',
        ),
      );
      pets.save(
        Pet(
          id: 'inexistente',
          usuarioId: 'outro-usuario',
          tipo: PetType.gato,
          nome: 'Pet de outra conta',
          genero: PetGenero.femea,
          peso: 4,
          dataNascimento: DateTime(2020),
          raca: 'Sem raça definida',
        ),
      );
      final agendamentos = InMemoryAgendamentoRepository();
      const endereco =
          'Rua das Flores e das Palmeiras com um nome bastante comprido, '
          '123 - Apartamento 42 - São Paulo - CEP 01001000';
      await agendamentos.save(
        _agendamento(
          usuarioId: usuario.id!,
          petId: 'pet-1',
          horario: '12:00',
          endereco: endereco,
        ),
      );
      await agendamentos.save(
        _agendamento(
          usuarioId: usuario.id!,
          petId: 'inexistente',
          horario: '13:00',
          status: StatusAgendamento.cancelado,
        ),
      );
      await agendamentos.save(
        _agendamento(
          usuarioId: 'outro-usuario',
          petId: 'pet-1',
          horario: '14:00',
          endereco: 'Endereço de outro usuário',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfiguracoesPage(
              usuarioRepository: usuarios,
              usuarioId: usuario.id,
              agendamentoRepository: agendamentos,
              petRepository: pets,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Histórico'));
      await tester.pumpAndSettle();
      expect(find.byType(HistoricoAgendamentoPage), findsOneWidget);
      expect(find.text('Pet não encontrado'), findsOneWidget);
      expect(find.text('Pet de outra conta'), findsNothing);
      expect(find.text('13:00'), findsOneWidget);
      expect(find.text('Endereço de outro usuário'), findsNothing);
      await tester.ensureVisible(find.text(endereco));
      await tester.pumpAndSettle();
      expect(find.text('01/01/2100'), findsWidgets);
      expect(find.text('12:00'), findsOneWidget);
      expect(find.text('Luna'), findsOneWidget);
      expect(find.text('Hemograma, Vacina'), findsWidgets);
      expect(tester.getSize(find.text(endereco)).height, greaterThan(30));
      expect(find.text('Editar'), findsNothing);
      expect(find.text('Deletar'), findsNothing);
      expect((await agendamentos.findByUsuarioId(usuario.id!)), hasLength(2));
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect(find.text('Meus Endereços'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('informa histórico vazio e falha no carregamento', (
    tester,
  ) async {
    final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final id = usuarios.findAll().single.id!;
    await tester.pumpWidget(
      MaterialApp(
        home: HistoricoAgendamentoPage(
          usuarioId: id,
          usuarioRepository: usuarios,
          agendamentoRepository: InMemoryAgendamentoRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nenhum agendamento encontrado.'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: HistoricoAgendamentoPage(
          key: const ValueKey('erro'),
          usuarioId: id,
          usuarioRepository: usuarios,
          agendamentoRepository: _RepositorioComErro(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Não foi possível carregar o histórico de agendamentos.'),
      findsOneWidget,
    );
    expect(find.text('Nenhum agendamento encontrado.'), findsNothing);
  });
}

Agendamento _agendamento({
  required String usuarioId,
  required String petId,
  required String horario,
  String endereco = '',
  StatusAgendamento status = StatusAgendamento.ativo,
}) => Agendamento(
  usuarioId: usuarioId,
  petId: petId,
  data: DateTime(2100),
  horario: horario,
  servicos: const [
    ServicoAgendamento(
      id: '1',
      categoria: CategoriaServico.exames,
      nome: 'Hemograma',
    ),
    ServicoAgendamento(
      id: '2',
      categoria: CategoriaServico.vacinas,
      nome: 'Vacina',
    ),
  ],
  convenio: ConvenioAgendamento.particular,
  endereco: endereco,
  status: status,
);

class _RepositorioComErro extends InMemoryAgendamentoRepository {
  @override
  Future<List<Agendamento>> findByUsuarioId(String usuarioId) =>
      Future.error(StateError('Falha ao carregar'));
}
