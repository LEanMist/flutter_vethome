import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/usuario.dart';
import 'package:flutter_vethome/pages/historico_agendamento_page.dart';
import 'package:flutter_vethome/pages/lista_enderecos.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final historico in [false, true]) {
      testWidgets(
        '${historico ? 'Histórico' : 'Endereços'} ocupa a barra de status e limita a rolagem em $platform',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(390, 844));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
          final usuario = usuarios.findAll().single;
          usuarios.save(
            usuario.copyWith(
              enderecosAdicionais: [
                for (var i = 0; i < 8; i++)
                  EnderecoUsuario(
                    nome: 'Casa $i',
                    cep: '01001000',
                    logradouro: 'Rua $i',
                    numero: '$i',
                    complemento: '',
                    cidade: 'São Paulo',
                  ),
              ],
            ),
          );
          final agendamentos = InMemoryAgendamentoRepository();
          for (var i = 0; i < 8; i++) {
            await agendamentos.save(
              Agendamento(
                usuarioId: usuario.id!,
                petId: 'pet-$i',
                data: DateTime(2100),
                horario: '${(i + 8).toString().padLeft(2, '0')}:00',
                servicos: const [
                  ServicoAgendamento(
                    id: '1',
                    categoria: CategoriaServico.exames,
                    nome: 'Hemograma',
                  ),
                ],
                convenio: ConvenioAgendamento.particular,
                endereco: 'Rua $i',
                status: StatusAgendamento.ativo,
              ),
            );
          }
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(platform: platform),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: const EdgeInsets.only(top: 32, bottom: 24),
                  viewPadding: const EdgeInsets.only(top: 32, bottom: 24),
                ),
                child: child!,
              ),
              home: historico
                  ? HistoricoAgendamentoPage(
                      usuarioId: usuario.id,
                      usuarioRepository: usuarios,
                      agendamentoRepository: agendamentos,
                    )
                  : ListaEnderecos(
                      usuarioId: usuario.id,
                      usuarioRepository: usuarios,
                    ),
            ),
          );
          await tester.pumpAndSettle();

          final page = find.byType(
            historico ? HistoricoAgendamentoPage : ListaEnderecos,
          );
          final safeAreas = find.descendant(
            of: page,
            matching: find.byType(SafeArea),
          );
          expect(safeAreas, historico ? findsNothing : findsOneWidget);
          final header = find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).color ==
                    VetCores.rosaEscuro,
          );
          expect(tester.getRect(header).top, 0);
          expect(tester.getRect(header).bottom, 120);
          expect(
            tester
                .getCenter(find.text(historico ? 'Histórico' : 'Endereços'))
                .dy,
            60,
          );
          expect(tester.getCenter(find.byTooltip('Voltar')).dy, 60);
          final overlay = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
            find.descendant(
              of: page,
              matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
            ),
          );
          expect(overlay.value.statusBarIconBrightness, Brightness.light);
          expect(overlay.value.statusBarColor, Colors.transparent);

          final lista = find.byType(ListView);
          if (historico) {
            expect(tester.getRect(lista).bottom, 820);
          } else {
            final botao = find.widgetWithText(ElevatedButton, 'Novo Endereço');
            expect(tester.getRect(lista).bottom, lessThan(tester.getRect(botao).top));
            expect(tester.getRect(botao).bottom, lessThanOrEqualTo(820));
          }
          expect(
            tester.widget<ListView>(lista).physics,
            isA<ClampingScrollPhysics>(),
          );
          expect(find.byType(StretchingOverscrollIndicator), findsNothing);
          expect(find.byType(GlowingOverscrollIndicator), findsNothing);
          final scrollable = tester.state<ScrollableState>(
            find.descendant(of: lista, matching: find.byType(Scrollable)),
          );
          await tester.drag(lista, const Offset(0, 400));
          await tester.pumpAndSettle();
          expect(scrollable.position.pixels, 0);
          await tester.drag(lista, const Offset(0, -5000));
          await tester.pumpAndSettle();
          expect(scrollable.position.maxScrollExtent, greaterThan(0));
          expect(
            scrollable.position.pixels,
            scrollable.position.maxScrollExtent,
          );
          await tester.drag(lista, const Offset(0, -400));
          await tester.pumpAndSettle();
          expect(
            scrollable.position.pixels,
            scrollable.position.maxScrollExtent,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
