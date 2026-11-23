# flutter_vethome

A new Flutter project.

## Contas e pets

O acesso utiliza e-mail e senha. Cada pet cadastrado pertence ao usuário
conectado e aparece apenas em seu menu e na seleção de agendamento.
Ao tocar no card do pet, é possível abrir seu perfil e escolher uma foto.
Em "Detalhes", são exibidos os dados do pet e o histórico de atendimentos
ativos e concluídos; somente a lista de atendimentos rola.
Em "Nova Consulta", o pet do perfil já fica selecionado; data, horário e
serviços são escolhidos antes da confirmação do agendamento.
O perfil lista os agendamentos ativos do pet. Eles passam a concluídos uma
hora após o horário marcado, conforme o relógio do aparelho; os status são
atualizados ao consultar os agendamentos.
Os dados são mantidos em memória e são perdidos ao reiniciar o aplicativo.

Os horários que já começaram ficam indisponíveis para novos agendamentos,
conforme o relógio do aparelho. Reservas ainda não são compartilhadas entre
aparelhos.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
