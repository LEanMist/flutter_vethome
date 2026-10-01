import 'package:flutter/material.dart';
import 'package:flutter_vethome/pages/cadastro_page.dart';
import 'package:flutter_vethome/pages/cadastro_pet_page.dart';
import 'package:flutter_vethome/pages/carregamento.dart';
import 'package:flutter_vethome/pages/escolha_pet_page.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_vethome/pages/menu_page.dart';
import 'package:flutter_vethome/pages/servicos_page.dart';
import 'package:flutter_vethome/pages/escolha_convenio.dart';

class TestePage extends StatelessWidget {
	const TestePage({super.key});

	@override
	Widget build(BuildContext context) {
		final telas = <({String titulo, IconData icone, WidgetBuilder pagina})>[
			(
				titulo: 'Login',
				icone: Icons.login,
				pagina: (_) => const LoginPage(),
			),
			(
				titulo: 'Cadastro',
				icone: Icons.person_add_alt_1,
				pagina: (_) => const InformacoesCadastroPage(),
			),
			(
				titulo: 'Escolha de pet',
				icone: Icons.pets,
				pagina: (_) => const EscolhaPetPage(),
			),
			(
				titulo: 'Cadastro de pet',
				icone: Icons.add_circle_outline,
				pagina: (_) => CadastroPetPage(
					destinoBuilder: (_) => const MenuPage(),
				),
			),
			(
				titulo: 'Carregamento',
				icone: Icons.hourglass_empty,
				pagina: (_) => Carregamento(
					destinoBuilder: (_) => const MenuPage(),
				),
			),
			(
				titulo: 'Menu',
				icone: Icons.home_outlined,
				pagina: (_) => const MenuPage(),
			),
			(
				titulo: 'Serviços',
				icone: Icons.medical_services_outlined,
				pagina: (_) => const ServicosPage(),
			),
      (
				titulo: 'Escolha de Convênio',
				icone: Icons.medical_services_outlined,
				pagina: (_) => const EscolhaConvenioPage(),
			),
		];

		return Scaffold(
			appBar: AppBar(title: const Text('Telas do projeto')),
			body: ListView.separated(
				padding: const EdgeInsets.all(20),
				itemCount: telas.length,
				separatorBuilder: (context, index) => const SizedBox(height: 12),
				itemBuilder: (context, index) {
					final tela = telas[index];
					return SizedBox(
						width: double.infinity,
						child: OutlinedButton.icon(
							onPressed: () {
								Navigator.push(
									context,
									MaterialPageRoute(builder: tela.pagina),
								);
							},
							icon: Icon(tela.icone),
							label: Text(tela.titulo),
							style: OutlinedButton.styleFrom(
								padding: const EdgeInsets.symmetric(vertical: 16),
							),
						),
					);
				},
			),
		);
	}
}
