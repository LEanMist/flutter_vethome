# VetHome

Aplicativo Flutter para organizar o atendimento veterinário em domicílio e os dados dos pets.

## O que já existe

- Cadastro e perfil do cliente, com endereços salvos.
- Cadastro, edição, detalhes e fotos de pets.
- Saúde, carteira de vacinação e agendamentos.
- Agenda com seleção de data, histórico e resumo dos próximos atendimentos.
- Persistência local em um snapshot versionado (`vethome.state.v1`). Pets, cliente, endereços, consultas e vacinas são restaurados ao reabrir o app. Fotos são guardadas como miniaturas locais.
- A preferência de tema fica salva no dispositivo ou navegador.
- A aba de conversa é uma demonstração local. As mensagens não são enviadas à veterinária.
- A área veterinária da Gabriela oferece perfil, mensagens, agenda e configurações; ela é independente da área do cliente.
- Fontes Comfortaa e Montserrat Alternates incluídas no app, para manter a tipografia sem baixar arquivos de fonte em tempo de execução.
- Modo Web responsivo, com layouts ajustados para celular e desktop.

O projeto ainda não usa autenticação real nem sincroniza dados com um servidor. Alguns atendimentos e dados clínicos são exemplos de demonstração. Existe uma camada HTTP experimental, mas os contratos observados ainda não foram confirmados e nenhuma tela depende dela.

## Executar

A entrada do Cliente segue Splash → Login → Pets em celular, tablet e desktop.
O cadastro também termina em Pets. Links antigos para `/home` abrem a lista de
pets. Em modo de depuração, o botão de grade abre o seletor de telas, incluindo
o acesso demonstrativo à área da Gabriela.

Use o Flutter 3.50.1, a versão fixada na integração contínua. Na pasta do projeto:

```powershell
flutter pub get --enforce-lockfile
flutter run -d chrome
```

Para iniciar em outro dispositivo, consulte os destinos disponíveis com `flutter devices` e troque `chrome` pelo destino desejado.

## Verificar alterações

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub --platform chrome
flutter build web --no-pub --no-web-resources-cdn
```

`--platform chrome` seleciona o runner de widgets no navegador neste SDK.
A validação com Flutter 3.50.1 no Windows precisou de um ajuste local no
runner para servir o CanvasKit. O comando `flutter test -d chrome` selecionou
o runner local para a suíte de widgets. Os resultados estão em
[CONTEXT.md](CONTEXT.md).

## Estado das plataformas

O workflow [Qualidade Flutter](.github/workflows/qualidade.yml) executa a
análise estática, os testes no runner local e os builds Web, Android debug e
Windows debug em `liminha`. A [preparação para demonstração](docs/distribuicao.md)
registra a auditoria de distribuição, os resultados por plataforma e o checklist.

## Estrutura útil

- `lib/pages/`: telas do aplicativo.
- `lib/data/`: repositório local, persistência e transporte HTTP experimental.
- `lib/models/`: modelos e serialização dos dados.
- `lib/widgets/`: componentes reutilizados.
- `assets/imagens/`: imagens e exports usados pela interface.
- `test/`: testes de persistência, regras, navegação e interface.
- `CONTEXT.md`: histórico técnico detalhado, decisões, validações e pendências das retomadas.

## Cuidados com dados

Os dados atuais ficam no armazenamento local do dispositivo/navegador, sem sincronização ou backup automático. A camada de persistência valida snapshots antes de gravá-los e bloqueia alterações quando encontra dados inválidos, preservando o conteúdo original para evitar sobrescrita acidental.

Se uma alteração ficar apenas na sessão por falha na gravação, abra **Configurações** e use **Tentar salvar novamente** antes de fechar o app.
