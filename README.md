# VetHome

Aplicativo Flutter para gerenciamento de informações de pets e acompanhamento
veterinário. O projeto inclui áreas para clientes e para a veterinária Gabriela,
com telas de perfil, mensagens, agenda e configurações.

## Requisitos

- Flutter SDK compatível com a restrição de Dart em `pubspec.yaml`.
- Um dispositivo ou destino disponível, como Windows, Android ou navegador.

## Executar

```powershell
flutter pub get
flutter run -d windows
```

Para executar no navegador, use `flutter run -d chrome`.

## Verificar

```powershell
flutter analyze
flutter test
```

## Organização

- `lib/pages/`: páginas e fluxos principais do aplicativo.
- `lib/pages/gabriela/`: telas e componentes específicos da área veterinária.
- `lib/screens/`: telas de fluxos existentes do app.
- `lib/data/`: repositórios e acesso a dados locais/serviços.
- `lib/models/`: modelos de domínio.
- `lib/theme/`: cores e configuração visual.
- `lib/widgets/`: componentes reutilizáveis.
- `test/`: testes de widgets, navegação e regras dos fluxos.
- `assets/`: imagens, ícones e fontes.

No aplicativo em execução, o ícone de painel no cabeçalho abre o catálogo
provisório de telas, útil para desenvolvimento e validação.
