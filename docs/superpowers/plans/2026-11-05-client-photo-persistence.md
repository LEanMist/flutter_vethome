# Persistir a foto do tutor — plano de implementação

> **Execução:** plano aplicado diretamente nesta sessão, sem commit ou push.

**Objetivo:** Restaurar a foto escolhida no Perfil depois de reinicializar ou recarregar o VetHome, no Web e em plataformas nativas.

**Arquitetura:** A foto será uma miniatura PNG Base64 opcional em `ClientData` dentro do snapshot local schema 1. `VetRepository` validará o formato e a quota combinada de todas as fotos; `PerfilPage` usará o transformador já existente e mostrará bytes persistidos por `Image.memory`, preservando caminhos antigos como fallback.

**Tecnologias:** Flutter/Dart, `SharedPreferences`, `image_picker` e `PetPhoto` existentes; nenhuma dependência nova.

**Especificação:** `docs/superpowers/specs/2026-11-05-client-photo-persistence-design.md`

## Restrições globais

- Campo opcional compatível com snapshots antigos; manter `schemaVersion: 1`.
- Máximo de 180.000 caracteres Base64 por foto e 1.500.000 no total de fotos de pets e tutor.
- Não persistir caminhos locais, bytes brutos, senhas ou foto em backend.
- Falha de gravação mantém a foto na sessão e informa que ela não foi persistida.
- Preservar o picker, o avatar padrão e os fallbacks legados do Perfil.
- Não instalar dependências nem alterar o SDK Flutter; não stage/commit/push.

## Foco de revisão

- Snapshot anterior sem `client.photoBase64`: deve carregar sem foto e preservar os demais dados.
- Campo com tipo incorreto ou PNG inválido: deve cair para avatar padrão sem descartar o snapshot.
- Foto do tutor somada às fotos dos pets acima de 1.500.000 caracteres: rejeitar sem mutação.
- Falha no armazenamento: manter a foto somente na memória e exibir mensagem clara.
- Foto persistida aberta no Web ou nativo: usar bytes e não depender do caminho temporário.

---

### Task 1: Serialização compatível da foto do tutor

**Arquivos:**
- Modificar `lib/data/local_storage.dart` (`ClientData`).
- Modificar `test/vet_home_step4b_test.dart`.

**Interface produzida:**
- `ClientData.photoBase64`, opcional e serializado como `client.photoBase64` somente quando não nulo.
- `ClientData.fromJson` aceita campo ausente e usa `PetPhoto.isValid` para aceitar PNG válido ou ignorar foto inválida sem invalidar os demais dados do cliente.

- [x] Escrever teste que round-tripa foto válida e testa snapshot antigo sem campo.
- [x] Executar `flutter test --no-pub test/vet_home_step4b_test.dart --plain-name "Foto do tutor"`; falha correta: o campo serializado está ausente.
- [x] Implementar o campo opcional e sua validação.
- [x] Reexecutar `flutter test --no-pub test/vet_home_step4b_test.dart`; 21/21 passaram.

### Task 2: Mutação persistente e quota combinada

**Arquivos:**
- Modificar `lib/data/vet_repository.dart`.
- Modificar `test/vet_home_finishing_test.dart` e `test/vet_home_step4b_test.dart`.

**Interface produzida:**
- `VetRepository.clientPhotoBase64`, inicializado/restaurado junto com `ClientData`.
- `static Future<bool> updateClientPhoto(String photoBase64)`, que valida PNG, aplica a quota combinada, enfileira o snapshot e retorna `flush()`.
- A validação compartilhada conta a nova/atual foto do tutor com as fotos de pets, sem contar duas vezes o valor que está sendo substituído.

- [x] Escrever testes de preservar foto carregada ao salvar outros campos e rejeitar inclusão que exceda a quota combinada. A validação de formato inválido já está coberta na Tarefa 1.
- [x] Executar os testes focados; ambos falham antes da implementação: o cliente perde a foto no snapshot e o pet acima da quota é aceito.
- [x] Implementar a restauração e mutação reusando o pipeline de `_save`/`flush`.
- [x] Reexecutar `flutter test --no-pub test/vet_home_step4b_test.dart`; 23/23 passaram.

### Task 3: Seleção e exibição no Perfil

**Arquivos:**
- Modificar `lib/pages/perfil_page.dart`.
- Modificar `test/vet_home_step3b_test.dart` e `test/vet_home_finishing_test.dart`.

**Comportamento:**
- `_mudarFoto` usa `PetPhoto.choose`, grava pela API do repositório e decodifica a miniatura para a sessão.
- `initState` restaura `clientPhotoBase64`; Web continua com `Image.memory`; caminho antigo segue fallback nativo/Web da sessão.
- A falha de gravação informa que a foto foi atualizada apenas nesta sessão.

- [x] Escrever testes de seleção/restauração por `MemoryImage`, mensagem de falha de gravação e preservar o teste existente de fallback nativo legado.
- [x] Confirmar RED: sem carregar `photoBase64`, o perfil não renderiza a foto armazenada; sem integração do picker, o repositório não recebe a imagem e a mensagem de sessão não aparece.
- [x] Implementar seleção redimensionada por `PetPhoto`, gravação via repositório, restauração por bytes e mensagem clara quando `flush()` falha.
- [x] Reexecutar testes focados: persistência/restauração do perfil e falha de armazenamento passaram; testes legados continuam incluídos na próxima validação conjunta.

### Task 4: Verificação e registro

**Arquivos:**
- Atualizar `CONTEXT.md` com o comportamento e as limitações verificados.

- [x] Executar a suíte completa: `flutter test --no-pub --concurrency=1` e `flutter test --no-pub` passaram com 258 testes e 1 caso exclusivo de Web ignorado pelo runner nativo. A execução serial revelou um bloqueio de isolamento no teste que simula falha de gravação; ele foi movido para o fim do arquivo e a limpeza não aguarda a fila da storage deliberadamente falha. O arquivo `vet_home_finishing_test.dart` passou 14/14 depois do ajuste.
- [x] Complementar a validação no Chrome com `flutter test --no-pub -d chrome`: suíte completa passou com 258 testes e 1 skip nativo; `vet_home_pet_images_test.dart` passou 11/11 e `vet_home_step3b_test.dart` passou com 5 testes e 1 skip nativo. A variante `--platform chrome` ainda trava no Flutter para Windows.
- [x] Executar `flutter analyze --no-pub` e `git diff --check`: análise sem problemas; diff check passou, com avisos Git de conversão LF/CRLF.
- [x] Executar `flutter build web --no-pub`: build concluído e dry run Wasm aprovado.
- [x] Conferir status e diff: trabalho permanece local, fora do stage, sem commit ou push; alterações de Detalhes do Pet e demais alterações existentes foram preservadas.
- [x] Revisão visual posterior do Detalhe mobile em `390 × 844 px` contra `PROFILE_PET_PAGE` (`2619:1228`): removido o badge de câmera extra e o retrato passou a ser a ação acessível para alterar a foto, preservando o asset com +/lápis. Teste focado de imagens passou 12/12, suíte Web Chrome passou 259 + 1 skip nativo, analyze passou, build Web concluiu e diff-check passou.
- [x] Reexecutar a suíte nativa após o refinamento: `flutter test --no-pub` passou com 259 testes e 1 teste exclusivo do Web ignorado pelo runner nativo.

Build nativo Android foi tentado novamente após as verificações locais e falhou em `:gradle:compileKotlin` por `AccessDeniedException` ao excluir o cache no SDK Flutter. Uma tentativa direta do Gradle com `-Pkotlin.incremental=false` reproduziu a mesma falha; nenhum cache/SDK foi apagado ou editado. Build Windows permanece indisponível sem Visual Studio com o workload C++.
