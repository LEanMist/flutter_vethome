# VetHome — contexto para continuar o projeto

## Estado atual — acabamento local de 04/10/2026

- Branch `kelvin`; Passo 4B publicado em `e75ea44e099efa0764072016b9fc4d9f2b8e90a9`. O lote acumulado posterior, incluindo este acabamento, continua **NÃO publicado e NÃO staged**, aguardando revisão do usuário. Não iniciar nova etapa automaticamente.
- As seções anteriores registram o estado de cada época. Em particular, as antigas limitações de foto de pet apenas na sessão e de editor sem avatar foram substituídas pelo acabamento descrito ao final. A foto do usuário continua limitada à sessão.
- `.gitignore` contém a alteração preexistente do usuário e foi preservado. Nenhum commit, push, merge, configuração ou teste de aplicativo Android/Windows foi feito neste acabamento.

## Repositório e branch

- Projeto Flutter: `flutter_vethome`.
- Repositório: https://github.com/LEanMist/flutter_vethome.
- Branch de trabalho: **`kelvin`**. Não alterar, fazer push ou merge para `main` sem autorização explícita.
- Este documento pertence à raiz do repositório e deve acompanhar as alterações na branch `kelvin`.
- Antes de trabalhar em outro PC, obter a versão publicada da branch `kelvin`, conferir `git branch --show-current` e `git status` e preservar alterações locais do usuário.

## Estado do Passo 1

O Passo 1 de padronização visual global foi realizado no código. A conferência de fidelidade exata com o Figma permanece pendente por falta de acesso ao contexto e aos screenshots do design via MCP.

O Passo 1 foi publicado na branch `kelvin` no commit `e0b4b1cd00a8ccac86fc1f5281d884a003b3d532` (`Padroniza visual global conforme Figma`).

Os seis arquivos de código alterados nesta etapa são:

| Arquivo | Alteração aplicada |
| --- | --- |
| `lib/main.dart` | Consome `VetTheme.light(themeSeed)`; mantém as rotas e argumentos existentes. |
| `lib/theme.dart` | Centraliza tema, fontes e valores visuais reutilizáveis, preservando a API `VH`. |
| `lib/theme/text_style_helper.dart` | Usa as constantes de fontes de `VH`, preservando nomes, tamanhos, pesos e consumidores dos helpers. |
| `lib/theme/theme_helper.dart` | Alinha o esquema legado e getters de cores à paleta `VetColors`, preservando a API original. |
| `lib/widgets.dart` | Reutiliza constantes de fontes, dimensões, raios, sombras e gradiente, preservando os valores existentes e a assinatura de `insetBox`. |
| `lib/widgets/vet_bottom_nav.dart` | Corrige assets por aba e seleção visual de Pets; informa seleção à acessibilidade e respeita a área segura inferior. |

`CONTEXT.md` é o documento adicional desta etapa. Não foram alterados arquivos de páginas, telas, dados, modelos, rotas, testes ou plataformas. Nenhuma rota, argumento, lógica de negócio ou callback de navegação foi alterado.

Não foram adicionados assets, fontes `.ttf` ou dependências. `pubspec.yaml` e `VetTones` permaneceram intactos. Os ajustes de lint sem efeito visual no `ThemeHelper` foram revertidos.

## Decisões visuais

- Paleta confirmada: rosa claro `#FAD3D5`, rosa/marrom `#C08081` e marrom escuro `#68442E`, definidos em `VetColors`.
- O fundo global continua rosa claro. O tema Material usa rosa/marrom em `secondary` e `outline`, marrom no texto de superfícies e branco sobre as cores primária e secundária.
- A cor primária continua ligada a `VH.themeSeed`, preservando a seleção de tema existente.
- Montserrat Alternates é a fonte global de corpo; Comfortaa é usada nos estilos globais de display, headline e `titleLarge`, além do título existente de `VHHeader`.
- O pacote `google_fonts` existente é usado no tema global. Permanecem registradas as fontes locais `ComfortaaBold.ttf` e `MontserratAlternatesBold.ttf`.
- Dimensões, raios, sombras e gradiente foram centralizados a partir dos valores existentes no código; não são novas medições confirmadas do Figma. O gradiente compartilhado mantém rosa/marrom → rosa claro.
- `VH`, `ThemeHelper`, `appTheme`, `TextStyleHelper`, `VetTones` e `PetsTheme` devem continuar compatíveis com seus consumidores.

### Navegação inferior

| Aba | Asset normal em `assets/imagens/figma/` | Asset selecionado |
| --- | --- | --- |
| Pets | `pets.png` | `pets-6.png` |
| Perfil | `frame-53.png` | `frame-51-2.png` |
| Whatsapp | `frame-52.png` | `frame-52-5.png` |
| Agenda | `frame-50.png` | `frame-52-3.png` |
| Configurações | `frame-49-2.png` | `frame-49.png` |

Pets usa círculo rosa claro quando não selecionado e rosa/marrom com pata branca quando selecionado. A barra mantém tamanhos, escala de `PetsTheme` e callbacks existentes. Foi acrescentado `Semantics.selected` e `SafeArea` inferior.

As rotas permanecem `/pets`, `/perfil`, `/chat`, `/agenda` e `/config`.

## Referência Figma

- Projeto: `Doutoura_Do_Vinicius`.
- URL: https://www.figma.com/design/p5Mv2Ej6kbfkgCfePLJKPr/Doutoura_Do_Vinicius?node-id=0-1.
- O Figma MCP está atualmente limitado pela cota/plano (erro de rate limit do Starter). Não foi possível obter contexto de design, estrutura de nós ou screenshots.
- O Figma continua sendo a referência visual. Enquanto estiver inacessível, usar cores confirmadas e assets existentes; não apresentar medidas, sombras, breakpoints ou gradientes inferidos como dados do Figma.

## Validação e lint preexistente

- `flutter test test/vet_home_screens_test.dart`: **8 testes passando**.
- Na revisão anterior à limpeza, `flutter analyze` mostrou **25 infos preexistentes fora dos seis arquivos alterados**, sem erros ou warnings.
- Após reverter ajustes de lint desnecessários, `flutter analyze` mostra **29 infos preexistentes**, sem erros ou warnings: as mesmas 25 externas e quatro restauradas em `lib/theme/theme_helper.dart` (dois campos que poderiam ser `final`, o parâmetro `_newTheme` e o getter `white_A700`). Não foram introduzidos novos erros ou warnings.
- O código de saída da análise é 1 por causa das infos; não significa falha de compilação. Não corrigir esses lints como parte da padronização visual.

Comandos para validar alterações nesta etapa:

```powershell
dart format lib/main.dart lib/theme.dart lib/theme/text_style_helper.dart lib/theme/theme_helper.dart lib/widgets.dart lib/widgets/vet_bottom_nav.dart
flutter analyze
flutter test test/vet_home_screens_test.dart
git diff --check
git diff --cached --check
```

O SDK deve ser localizado no PC em uso; não presumir um caminho fixo de instalação.

## Foto de Perfil no Flutter Web

Antes do Passo 3B, `lib/pages/perfil_page.dart` usava `Image.file(_foto!, ...)` também no navegador, causando `Image.file is not supported on Flutter Web`.

A partir do Passo 3B, o Web lê os bytes do `XFile` retornado pelo `image_picker` e renderiza com `Image.memory`. `VetRepository.clientPhotoBytes` conserva a foto durante a sessão e ao retornar à tela; `clientPhotoPath` continua disponível. Se só houver caminho no Web, tenta recuperar os bytes via `XFile`, mantendo o avatar padrão se o caminho expirou. Plataformas nativas continuam usando `File`/`Image.file` e o caminho existente.

## Preservação e próximos passos

- Manter mudanças pequenas e limitadas ao objetivo visual; não fazer limpeza de lint ou refatoração geral.
- O escopo de código do Passo 1 é `lib/main.dart`, `lib/theme.dart`, `lib/theme/*`, `lib/widgets.dart` e `lib/widgets/vet_bottom_nav.dart`; alterar `pubspec.yaml` somente se necessário. Mudanças em outras áreas precisam de autorização.
- Preservar mudanças locais do usuário. A alteração preexistente em `.gitignore` para `.widget_preview/` pertence ao usuário e deve ficar fora do commit do Passo 1.
- Não aplicar automaticamente stashes ou branches de backup antigos.
- Quando o acesso ao Figma estiver disponível, conferir o tema global e a barra inferior contra os nós e screenshots reais, incluindo as cinco abas e a área segura mobile.
- A incompatibilidade de foto no Flutter Web foi corrigida no Passo 3B. Persistência de fotos entre sessões/recarregamentos e validação física de câmera/dispositivos nativos são trabalhos separados.
- Para recuperar novas etapas em outro PC pelo GitHub, as alterações precisam de commit e push autorizados na branch `kelvin`; arquivos apenas locais ou no stage não são publicados.

## Passo 2 — ajustes locais em Pets e Perfil

O escopo inicial desta etapa é o visual das telas Pets e Perfil. Também foi autorizada a correção compartilhada de áreas inferiores vazias em `VHHeader`, com atualização deste documento. A paleta e a tipografia globais permanecem intactas.

- `lib/pages/pets_page.dart`: removido o retângulo arredondado vazio abaixo do título Pets. A lista, seus dados, ações e navegação permanecem iguais.
- `lib/widgets/pets/pet_card_widget.dart`: removido o fundo circular rosa claro dos ícones de cachorro/gato. Os assets, o tamanho dos ícones, o espaço reservado na linha e o comportamento dos itens foram preservados. Este widget é consumido somente pela tela Pets.
- `lib/pages/perfil_page.dart`: removidas as duas sombras do círculo da foto. O avatar padrão usa o asset plano existente `assets/imagens/figma/frame-53-3.png`, sem a sombra embutida de `frame-53.png`. Foram preservados o alinhamento central, as dimensões, a moldura, o contorno tracejado, as opções e os toques para editar nome e foto.
- Nenhum asset novo foi criado. Nenhuma rota, lógica de negócio ou navegação foi alterada. A incompatibilidade preexistente de `Image.file` no Web permanece apenas documentada.
- `dart format` foi executado nos quatro arquivos de código, incluindo `lib/widgets.dart` após a correção compartilhada. `flutter test test/vet_home_screens_test.dart`: 8 testes passando.
- `flutter analyze` nos quatro arquivos de código desta etapa: sem ocorrências. `git diff --check`: sem problemas de whitespace.
- A comparação exata com o Figma permanece pendente; estes ajustes seguem as orientações visuais do usuário e reutilizam assets existentes.
- O Passo 2 foi aprovado, commitado e publicado em `origin/kelvin` no commit `fbbe9104f214c1b5d2606a0ef911c30173d5dd1d` (`Ajusta detalhes visuais de Pets e Perfil`). A conferência visual em dispositivo mobile e a comparação exata com o Figma, quando o MCP estiver disponível, permanecem como validações futuras, não como pendências de publicação desta etapa.

### Correção compartilhada de `VHHeader`

- Em `lib/widgets.dart`, a caixa inferior arredondada, sua decoração e sombra só são renderizadas quando `bottom != null`.
- Sem `bottom`, o cabeçalho deixa de reservar a altura dessa área: tem 64 px com título e botões, ou 80 px quando também existe subtítulo. Essas alturas são escolhas de layout locais; não são medidas confirmadas do Figma.
- Com `bottom`, permanecem a altura original de 125 px, posição, dimensões, decoração e conteúdo da caixa. Serviços e Convênio fornecem `_PetTypeTag` nesse slot e conservam o layout anterior.
- Os consumidores sem `bottom` corrigidos são `SobreScreen`, `ChatScreen` (Whatsapp), `ConfigScreen`, `EscolhaPetScreen` e as implementações legadas `PetsScreen`, `PetScreen`, `EditPetScreen` e `PerfilScreen`.
- `PetsPage` e `PerfilPage` têm cabeçalhos próprios. A remoção do bloco vazio de `PetsPage` continua necessária e foi mantida; a correção de `VHHeader` não substitui esse ajuste. Também foram preservados os ícones de animais sem círculo e o avatar plano de Perfil.
- Rotas, callbacks, lógica de negócio e navegação permanecem inalterados. Nenhum arquivo de outras telas foi editado para aplicar a correção compartilhada.

## Passo 3A — correções objetivas da auditoria

- O Passo 3A foi aprovado, commitado e publicado em `origin/kelvin` no commit `b712cc136d793072dbee58d8c46c3a118a80bc1a` (`Corrige problemas visuais e responsivos do Passo 3A`). O Passo 2 continua publicado no commit `fbbe9104f214c1b5d2606a0ef911c30173d5dd1d`.
- `lib/pages/login_page.dart`: o conteúdo passou a ser rolável, preservando elementos, dimensões visuais existentes, autenticação, validações e navegação. Capturas Web em 320 × 640 e 320 × 480 não apresentaram overflow vertical; o link de cadastro continua acessível por rolagem.
- `lib/widgets/vet_header.dart`: a caixa inferior só existe quando `bottom != null`. Sem conteúdo, sua altura não é reservada. Com conteúdo, mantém largura e decoração existentes e usa a altura anterior como mínimo, permitindo acomodar conteúdo maior. Isso corrige as caixas vazias de Detalhes, Editar pet, Vacinação, Agendamentos e Novo agendamento.
- `lib/pages/saude_page.dart`: avatar e nome organizados em coluna centralizada, com nome completo permitindo quebra de linha e altura adaptável do slot. Captura em 390 × 844 e teste com nome longo não apresentaram corte do conteúdo.
- Os assets foram inspecionados: `assets/imagens/figma/cachorroegatopng-2.png` representa cachorro; `cachorroegatopng-3.png` representa gato. `lib/widgets/pets/pet_card_widget.dart` agora associa esses assets às espécies corretas, mantendo a regra de identificação de espécie existente e os ícones sem círculo.
- `lib/screens/auth.dart`: a ilustração fixa de Cadastro Pet usa o asset de cachorro, correspondente ao tipo padrão do formulário, em vez do gato anterior. Campos, validações e cadastro permanecem inalterados.
- `lib/widgets/pet_avatar.dart`: corrige na apresentação os dois caminhos legados invertidos, sem modificar `PetModel.imagePath` ou dados em `VetRepository`. Para essas duas silhuetas, aplica fundo `VetColors.rose`, dando contraste nos cards de Detalhes, Vacinação, Agendamentos e Novo agendamento, e também no avatar de Saúde. Outros assets/fotos mantêm o caminho original e não recebem esse fundo colorido.
- `test/vet_home_step3a_test.dart`: cinco testes de regressão para ausência da caixa vazia, altura adaptável, Saúde com nome longo, mapeamento de espécies e contraste dos avatares sem alteração dos dados. A suíte existente `test/vet_home_screens_test.dart` mantém os oito testes passando.
- Análise dos seis arquivos de código e do novo teste: sem ocorrências. Não foram alteradas rotas, lógica de negócio, navegação, dados, dependências, arquivos de assets, tema global ou `.gitignore`.
- Limitações preservadas: fidelidade exata ao Figma continua pendente por limite do MCP; `Image.file` no Perfil Web não foi corrigido; detalhes decorativos laterais do Login em largura estreita e o título truncado de Novo agendamento permanecem fora destas correções. Não foi feita padronização geral de sombras ou formulários.

## Passo 3B — Login estreito, título e foto Web

- O Passo 3B foi concluído e publicado em `origin/kelvin` no commit `eb23aa26bd2902a1a14c02e0971ecc68c13e3971` (`Corrige responsividade e suporte Web do Passo 3B`). As três pendências de Login, título e foto Web registradas no Passo 3A foram tratadas aqui.
- `lib/pages/login_page.dart`: a escala da decoração da pata agora considera a largura disponível, incluindo os dedos laterais posicionados fora da caixa, suas rotações e sombras. Elementos, campos, botões, textos, autenticação e rolagem permanecem iguais. Validado visualmente em 320 × 480, 320 × 640 e 390 × 844, sem cortes laterais problemáticos ou overflow vertical. O cálculo é uma escolha local, não uma medida do Figma.
- `lib/widgets/vet_header.dart`: o título completo mantém fonte/texto existentes, com `FittedBox` e `BoxFit.scaleDown` apenas quando a largura entre os botões não é suficiente. Voltar, diagnóstico, slot inferior e ausência da caixa vazia permanecem preservados. Novo agendamento foi conferido em larguras de 320 e 390 px; Detalhes, Editar pet, Saúde, Vacinação e Agendamentos também foram conferidos.
- `lib/pages/perfil_page.dart` e `lib/data/vet_repository.dart`: adaptação mínima para bytes no navegador, descrita acima. O picker, avatar padrão, moldura, dimensões e ações do Perfil foram mantidos. Nenhuma dependência ou asset novo foi adicionado.
- `test/vet_home_step3b_test.dart`: regressões para escala da decoração do Login, títulos completos/botões em dois tamanhos, avatar padrão, restauração em memória no Web sem `FileImage`, manutenção de `FileImage` nativo e seleção nativa via picker simulado. Os testes específicos de cada plataforma são executados somente nela.
- Validação: oito testes existentes, cinco do Passo 3A e cinco do Passo 3B passando no runner nativo; o teste exclusivo do Web é ignorado nesse runner. Análise dos arquivos alterados sem ocorrências e `git diff --check` aprovado. No app Web, a seleção real pelo `image_picker`, o avatar padrão e a manutenção da foto ao reabrir Perfil foram conferidos por capturas. A execução da suíte pelo runner Chrome ficou bloqueada antes dos testes por erros 404 nos arquivos locais do motor gráfico (CanvasKit e skwasm); isso não impediu executar e validar o app no navegador.
- Limitações: cache da foto é apenas da sessão, como os demais dados do repositório de exemplo; câmera e permissões precisam de validação em dispositivos físicos. Fidelidade exata ao Figma permanece pendente pelo limite do MCP. Não foram alterados Pets, Escolha de Pet, paleta, fontes globais, sombras ou formulários.

## Passo 4A — preparação dos modelos e relacionamentos

- O Passo 4A foi aprovado, commitado e publicado em `origin/kelvin` no commit `e54b5763a2c10afde2a72d1966e3edc2fd434103` (`Prepara arquitetura de dados do Passo 4A`). Essa etapa não adicionou persistência, dependências, backend, autenticação real ou mudanças visuais gerais.
- `lib/screens/auth.dart`: os formulários mantêm rótulos e validações, mas usam chaves separadas `client.*` e `pet.*`. As colisões de `Data de Nascimento` e `Gênero/Sexo` foram eliminadas; os campos de pet não são preenchidos pelos dados do usuário. `registerClient` lê somente chaves `client.*`; `clientGender` conserva o gênero do usuário em memória. O cadastro isolado de pet não registra/altera o cliente.
- `lib/models/pet_model.dart`: cada pet tem `id` final independente do nome. Exemplos usam `pet-demo-1` a `pet-demo-4`; novas instâncias geram `pet-<microssegundos>-<contador>` sem UUID/dependências. `copyWith` preserva o ID; o construtor permite informar o ID para futura restauração de dados. Os IDs gerados ainda não são salvos após reiniciar.
- `lib/data/vet_repository.dart`: agendamentos locais são relacionados por ID; edição e exclusão localizam o pet por ID, inclusive com instância reconstruída. Edição rejeita troca de identidade. Exclusão remove somente os eventos daquele ID. Seleção usa `selectedPetId` e `selectedPet`; `selectedPetIndex` permanece como adaptador das telas antigas, não como armazenamento. Eventos para ID inexistente são rejeitados.
- Removido `_perfis`, que duplicava espécie, peso, castração e idade. `PetModel` é a fonte principal; `PetProfile` é uma projeção derivada por ID. Idade é calculada pelo nascimento; `ageYears` preserva apenas a idade demonstrativa dos três pets sem nascimento conhecido. `description` permanece como texto legado por compatibilidade, não como fonte dos campos estruturados; a projeção `Pet` de `lib/widgets.dart` continua somente para apresentação.
- Consumidores passaram a enviar ID em `lib/pages/agendamentos_page.dart`, `lib/pages/detalhes_pet_page.dart`, `lib/pages/nova_consulta_page.dart`, `lib/pages/saude_page.dart`, `lib/pages/vacinacao_page.dart` e `lib/screens/outros.dart`. A edição em `lib/pages/editar_pet_page.dart` usa `copyWith`. Agenda e Histórico exibem o nome atual associado ao ID.
- Lista vazia: `lib/main.dart` resolve pets canônicos e oferece `PetsPage` nas rotas que exigem pet quando nenhum é encontrado; nomes de rotas continuam iguais. Argumento legado `petName` é aceito somente como compatibilidade de entrada, resolvendo um registro existente, sem criar identidade por nome. `lib/pages/teste_page.dart` não usa mais `.first` e oferece Pets no catálogo quando necessário. Escolha de Pet, Serviços e Convênio em `lib/screens/pets.dart` oferecem a tela Pets existente com botão de cadastro quando não há pets.
- `test/vet_home_step4a_test.dart`: regressões para cadastro completo separado, cadastro isolado nas duas direções, IDs únicos/cópia estável, renomeação e modal de edição, perfil derivado, exclusão por ID/reutilização de nome, seleção após exclusão e zero pets nas telas ativas. Testes existentes preservados.
- Revisão final: o catálogo resolve o pet selecionado ao abrir cada tela, sem capturar uma referência antiga na montagem do menu. Assim, excluir todos os pets com o catálogo já aberto também oferece Pets, em vez de abrir uma nova consulta para um pet excluído. Acrescentada regressão para esse cenário objetivo.
- Validação do Passo 4A: `dart format` nos arquivos Dart desta etapa; análise dos arquivos alterados sem ocorrências; oito testes existentes, cinco do Passo 3A, cinco executáveis do Passo 3B, onze do Passo 4A e dois do catálogo passando (31 no total). O teste exclusivo do Web continua ignorado no runner nativo. Build Web e verificação de compilação Wasm aprovados; `git diff --check` aprovado. Nenhuma dependência nova; `.gitignore` preservado fora do stage.
- Limitações ao encerrar o Passo 4A: todos os dados ainda estavam em memória. Consultas, vacinas e despesas são mocks sem histórico clínico próprio por pet; recebem ID, mas não implementam CRUD. Os eventos fixos de janeiro de 2026 da Agenda e sua data inicial permanecem demonstrativos. Login continua simulado; fotos não são permanentes. Telas/rotas legadas não usadas pelo entrypoint atual não foram refatoradas. A persistência posterior é descrita no Passo 4B abaixo.

## Passo 4B — persistência local com JSON

- Naquele momento, o Passo 4B estava implementado localmente na branch `kelvin`, ainda sem commit ou push. Posteriormente foi publicado no commit `e75ea44e099efa0764072016b9fc4d9f2b8e90a9` (`Implementa persistencia local do Passo 4B`). O Passo 4A havia sido publicado no commit `e54b5763a2c10afde2a72d1966e3edc2fd434103`. O lote de acabamento atual permanece local, não publicado.
- Adicionado `shared_preferences: ^2.5.5` em `pubspec.yaml`, resolvido como **2.5.5** por `flutter pub get`, sem `pub upgrade`. `pubspec.lock` inclui o pacote e seis implementações/interface transitivas. A resolução pelo SDK deste PC também atualizou as transitivas `intl` 0.20.2 → 0.20.3, `matcher` 0.12.19 → 0.12.20, `meta` 1.18.0 → 1.19.0, `test_api` 0.7.11 → 0.7.12 e `vector_math` 2.2.0 → 2.4.3; não foram adicionadas outras dependências diretas.
- `lib/data/local_storage.dart` centraliza carregar, salvar e limpar apenas a chave lógica **`vethome.state.v1`**. Usa a API `SharedPreferences` com mock oficial; faz `reload()` antes de carregar para não reutilizar cache antigo. No Web, o plugin usa LocalStorage e prefixa a chave com `flutter.`. Os plugins existentes do pacote atendem Android e Windows sem condicionais próprias de plataforma.
- Um único snapshot JSON contém `schemaVersion: 1`, `client`, `pets` e `appointments`. `ClientData` serializa nome, nascimento, endereço, telefone, e-mail e gênero. `PetModel` serializa todos os campos, incluindo ID, campos opcionais e `ageYears` demonstrativo. `Agendamento` serializa `petId`, data/hora em um ISO 8601, serviço (`tipo`), veterinário, local/convênio (`local`), status por nome e descrição. A relação por ID continua no mapa do repositório, sem usar nome como chave.
- `lib/models/json_fields.dart` valida tipos e datas do snapshot. ID vazio/ausente, IDs duplicados, eventos órfãos, status desconhecido e versão incompatível não são aceitos. A versão gravada é `schemaVersion: 1`; versão ausente, de tipo textual ou desconhecida/futura aciona o mesmo fallback seguro de snapshot inválido, preservando o conteúdo no storage até uma gravação válida posterior. A restauração é integral: nenhum estado parcial é aplicado. Não há migrações automáticas.
- `VetRepository` continua sendo a interface das telas. Cadastro/edição de cliente, cadastro/edição/exclusão de pet e inclusão de agendamento disparam automaticamente a gravação de um snapshot. A fila captura o estado de cada alteração e grava em ordem; `flush()` permite aguardar e retorna sucesso/falha; `lastPersistenceError` conserva eventual falha. Erros de gravação não geram exceções assíncronas não tratadas e não bloqueiam tentativas posteriores. Não foi acrescentado alerta visual de falha de gravação.
- `lib/main.dart` agora inicializa o binding e aguarda `VetRepository.initialize()` **antes de `runApp`**. As rotas, autenticação simulada, validações, aparência e callbacks de navegação não foram alterados. Nenhuma alteração foi feita na branch `main`.
- Sem snapshot na primeira execução: mantém os quatro pets demonstrativos e o cliente inicial, sem gravar automaticamente esses mocks. Com snapshot válido: substitui a lista inteira pelos pets salvos. Uma lista salva **vazia** permanece vazia nos próximos reinícios; não recria os exemplos. Renomeação mantém ID; exclusão remove também somente os agendamentos daquele ID, inclusive no snapshot.
- Persistem apenas agendamentos criados pelo usuário. Eventos demonstrativos de `agendamentos()` e da Agenda continuam separados e não são convertidos em registros reais. Consultas, vacinas e despesas continuam mocks; chat, tema, seleção do pet, autenticação e senha não são persistidos.
- Snapshot ausente, inválido/corrompido ou armazenamento indisponível: usa cliente inicial/quatro pets, sem derrubar o app. Conteúdo inválido não é apagado nem substituído só por carregar; uma alteração posterior bem-sucedida passa a gravar o novo estado válido. Não há recuperação parcial, backup ou migração de versão ainda.
- Foto continua **somente na sessão**, em todas as plataformas. O picker nativo não copia a imagem para um diretório permanente controlado pelo app; caminhos de câmera podem ser temporários. No Web, URL blob é temporária. Nenhum caminho de foto do cliente, bytes ou Base64 são gravados nas preferências. `PetModel.imagePath` continua representando os assets existentes dos pets.
- Limites: persistência simples para o TCC, não armazenamento crítico, criptografado ou multiusuário. Gravações são assíncronas; encerramento abrupto antes de completar uma gravação pode perder a última alteração. No Web, os dados pertencem à origem/perfil do navegador e são perdidos ao limpar seus dados; não são sincronizados entre PCs ou dispositivos. Android e Windows usam os plugins do pacote, mas encerramento/reabertura em dispositivos nativos ainda precisa de validação prática.
- Arquivos desta etapa: `CONTEXT.md`, `pubspec.yaml`, `pubspec.lock`, `lib/data/local_storage.dart`, `lib/data/vet_repository.dart`, `lib/main.dart`, `lib/models/json_fields.dart`, `lib/models/pet_model.dart`, `lib/models/vet_models.dart` e `test/vet_home_step4b_test.dart`. `.gitignore` preservado com a alteração local preexistente do usuário, fora do stage.
- `test/vet_home_step4b_test.dart`: **20 testes** com `SharedPreferences.setMockInitialValues`, isolados por setup/teardown. Cobrem serialização completa/opcional, rejeição de tipos/datas/IDs inválidos, cliente, pets após reload, lista vazia, renomeação estável, exclusão e não reutilização de ID, agendamentos por ID, separação dos mocks/dados de sessão, JSON/estrutura/preferência corrompidos, ordem de gravação, falha/recuperação de gravação e limpeza somente da própria chave. Na revisão final, os testes existentes foram reforçados para confirmar recuperação por gravação válida após JSON inválido; schema ausente/textual/futuro sem sobrescrita ao carregar; ciclo criar evento → reload → renomear → reload → excluir → reload; ausência de duplicação de mocks em reloads repetidos; e 20 gravações com a primeira bloqueada por `Completer`, preservando a ordem de início/conclusão e no máximo uma gravação ativa. Nenhum código de produção precisou mudar nessa revisão.
- Validação: **51 testes passando** (8 existentes, 5 do Passo 3A, 5 executáveis do 3B, 11 do 4A, 20 do 4B e 2 do catálogo); 1 teste exclusivo do Web ignorado no runner nativo. Análise dos sete arquivos Dart alterados sem ocorrências. Build Web, dry run Wasm e `git diff --check` aprovados.
- Teste real no build Web com Chrome/perfil isolado: nome do cliente e do pet editados pelas telas, agendamento criado pela tela de nova consulta, navegador encerrado completamente e reaberto na mesma origem/perfil. Snapshot preservado integralmente; Perfil e Pets exibiram os nomes restaurados e Agenda mostrou o evento salvo. Conferidos ID do pet, vínculo, horário, status e descrição no snapshot. A Agenda existente não exibe nome do pet nem descrição nos cards; isso não foi alterado para este teste. Não foram usados dados nem preferências do navegador pessoal do usuário.
- Próximos passos: conferir o ciclo completo de persistência em Android/Windows, decidir armazenamento permanente de fotos em etapa separada e evoluir os históricos clínicos demonstrativos somente com escopo aprovado. Não adicionar backend, autenticação real ou reformulação visual como consequência automática desta etapa.


## Revisão ampla de UX e fluxos — lote local NÃO publicado (04/10/2026)

- Base publicada: Passo 4B, commit `e75ea44e099efa0764072016b9fc4d9f2b8e90a9`, branch `kelvin`. Este lote e as correções locais recentes continuam sem commit/push; a alteração preexistente de `.gitignore` foi preservada integralmente (SHA-256 conferido).
- Foram preservadas/evoluídas as correções anteriores de rotas nomeadas, Agenda por data, próximo agendamento, barra inferior do Convênio e criação de consultas futuras. Nenhuma alteração/configuração/validação em Android ou Windows.
- Formulário compartilhado `VHField`: degradê da paleta confirmada, ícones alinhados, foco visível, seleções apropriadas, máscaras sem pacote adicional (nascimento/CPF/CEP/telefone/peso) e autocomplete de raças por espécie com filtro sem acentos. Telas ativas limitam a largura no desktop e foram verificadas em 320 px. Datas de nascimento validam calendário real; datas de agenda não recebem a máscara de nascimento.
- Login: composição com assets atuais, link Cadastre-se pequeno/em negrito, botões sociais com feedback “Login social em breve.”, sem autenticação externa. Cadastro mantém chaves separadas de cliente/pet, gênero selecionável e descrição opcional para Outro. Trocar a espécie limpa a raça. Endereço e pet podem ser pulados sem criar registros vazios.
- Endereço: somente CEP/Endereço/Cidade/Número/Complemento, nessa ordem; número obrigatório e complemento opcional. Consulta ViaCEP com estados de carregamento/inexistente/falha, preenchimento editável, proteção contra respostas atrasadas e confirmação de divergência. `http` 1.6.0 já estava no lockfile; passou a dependência direta, sem atualização de versões.
- Boas-vindas: título fixo, logo limpa sobe uma vez e para, frase aparece depois da chegada; mensagem específica para zero pets e navegação automática para Pets. `origin/leandro` foi lida somente como referência; não houve merge nem cópia de sua arquitetura/animação com giro/queda.
- Pets: lista com rolagem interna e botão + externo, cards com feedback de toque/hover e avatar compartilhado. Detalhes começam recolhidos, expandem dados reais, oferecem Nova Consulta principal e lápis discreto; exclusão com confirmação fica no final do editor. Renomear na mesma espécie preserva o avatar.
- Serviços/Convênio: resumo compacto do pet; categorias expansíveis consistentes; escolha de plano avança imediatamente. Pet/serviço/plano passam pelas rotas; agendamento mantém vínculo por ID e exibe o nome atual e vacina/exame selecionado.
- Nova Consulta: início/fim responsivos, descrição opcional até 500 caracteres e confirmação acima da barra inferior. Horários passados desabilitados, rechecados ao tocar e ao salvar; fim deve ser posterior ao início. Mantida a grade de horários existente (início 12–16h; fim 13–17h), sem criar regra de funcionamento adicional. Eventos antigos/mocks não são revalidados nem alterados.
- Agenda: mês atual na entrada normal; data específica quando recebida pelo fluxo. Dia com nome completo, Nova Consulta prioritária e eventos em ordem cronológica. Exemplos são identificados como demonstração e não contam como próximo evento real.
- Configurações mais leves, acesso à tela Sobre existente e ao gerenciamento de múltiplos endereços. Vacinação separa resumo e vacinas, deriva contagem/status e identifica dados demonstrativos. Histórico e próximo evento usam registros criados pelo usuário.
- Persistência permanece em `vethome.state.v1`, schemaVersion 1. Adicionados `client.genderCustom` (ausente -> vazio), `client.addresses` e `Agendamento.endDate` opcional. Snapshot antigo sem lista de endereços conserva TODO o endereço simples em um registro legado, sem adivinhar número/CEP/cidade. Lista explicitamente vazia permanece vazia. `clientAddress` permanece compatível como representação do primeiro endereço; IDs de pets/agendamentos permanecem estáveis.
- Novos arquivos: `lib/core/utils/form_fields.dart`, `lib/data/cep_service.dart`, `lib/models/saved_address.dart`, `lib/pages/addresses_page.dart`, `lib/widgets/address_form.dart`, `lib/widgets/pet_summary.dart`, `test/vet_home_revision_test.dart`. Os testes locais anteriores de navegação/horário foram preservados.
- Validação automática final: `flutter test` — 84 testes passando e 1 skip esperado (`Perfil Web restaura bytes e nunca usa FileImage`, exclusivo Web no runner padrão). A suíte inclui os 20 testes de persistência do Passo 4B e 23 regressões desta revisão. Mensagens de falha de storage na suíte são casos de corrupção/falha simulados deliberadamente. `flutter analyze` — 0 erros, 0 warnings, 29 infos preexistentes em arquivos não alterados por este lote; retorno 1 por essas infos, sem ocultá-las.
- Build Web final aprovado (232,9s), incluindo dry run Wasm. `git diff --check` final sem problemas.
- Validação manual do build Web em origem isolada `127.0.0.1:8766` (não alterou os dados da origem pessoal 8765): fluxo Login/Pets/Detalhes/Serviços/V10/Particular/Agenda; data correta; renomeação e próximo evento preservados; consulta, pet e endereço restaurados após refresh; Perfil aceitou 03102000 como 03/10/2000; CEP público 01001-000 preencheu Praça da Sé/São Paulo e permitiu salvar sem complemento. Verificações visuais em 320x640 e 1280x800. O fluxo inicial existente retorna ao Login após refresh; o teste reentrou para conferir os dados. Console sem erros/warnings observados.
- Limitações/pendências: acesso Figma MCP bloqueado pela quota do plano Starter; medidas e fidelidade exata não foram confirmadas. Layout usa paleta/assets atuais e escolhas locais de espaçamento, não medidas inventadas do Figma. Fontes existentes, nenhum .ttf novo. ViaCEP depende de rede e pode retornar logradouro vazio em CEP genérico (preenchimento manual permitido). Fotos continuam só na sessão; clínica/vacinas continuam demonstrativas; login social, autenticação real, backend/Firebase/OAuth e testes nativos permanecem fora deste lote. Revisão visual exata com Figma fica pendente, sem iniciar automaticamente outra etapa.


## Correções finais funcionais e alinhamento Figma — lote NÃO publicado (04/10/2026)

- Branch `kelvin`, HEAD `e75ea44e099efa0764072016b9fc4d9f2b8e90a9`. Todo o lote local anterior foi preservado. `.gitignore`, dependências, lockfile, entrypoint e armazenamento permaneceram byte a byte iguais ao início desta tarefa; nenhum commit, push, merge ou alteração de configuração nativa.
- Cadastro: CPF exige exatamente 11 dígitos; telefone aceita somente 10/11. Entradas incompletas exibem mensagem específica e bloqueiam o avanço. Máscaras e representação existente preservadas; nenhum algoritmo novo de dígitos verificadores.
- Histórico em Configurações ordena uma cópia dos eventos reais por DateTime inicial crescente, sem alterar o repositório. Saúde recebe “Dados demonstrativos” com texto que delimita vacinação, vermifugação e histórico; peso só é incluído nesse escopo quando não há peso real cadastrado.
- Login tem variante própria: quatro almofadas e corpo principal da pata com exports já existentes, logo 166, campos 242x48, Lembre-se/recuperação na mesma linha, Entrar 303x54 com ícone, separador e círculos sociais 56. Login social continua apenas com feedback, sem OAuth. Mantidos mostrar senha, rotas e catálogo de teste.
- Formulários de cadastro usam variante opt-in de VHField: altura 56, prefixo 58, borda 4, início rosa 25%, títulos Comfortaa 30 e painéis raio 30/borda 3/branco 20%. Endereço conserva somente CEP, Endereço, Cidade, Número e Complemento, agrupados em painel branco. ViaCEP, divergência, pular, máscaras, seleção e múltiplos endereços preservados.
- PetAvatar centraliza silhuetas canônicas de cachorro/gato. Pets e Escolha usam corpo inteiro 32x36 sem círculo individual; foto existente mantém prioridade e avatares de outros contextos conservam sua composição. Cards altura 52, raio 25, nomes Comfortaa 20 brancos e setas duplas; botão + marrom 107x47 fora da lista rolável.
- Serviços/Convênio reutilizam pílulas menores com setas marrons, subopções de Exames agrupadas e pictogramas de casa com cruz/estetoscópio/cápsulas. Seleção, hover/animação, avanço direto e argumentos pet/serviço/plano preservados.
- Agenda usa células de altura 44 independente da largura, calendário centralizado e faixa de data 258x41 sobreposta 21 px. Datas normais marrons; consultas conservam contexto e ação prioritária. Nova Consulta usa pílulas de data/início/fim, empilha horários em 320, descrição inicial maior e confirmação acessível. Regras de horário/ID/persistência não foram modificadas.
- Ajustes compartilhados: bottom nav altura 70/raio 25, escala de Pets limitada no desktop, cabeçalhos e composição de Boas-vindas aproximados. Animação continua com título fixo, logo apenas subindo e navegação automática. Sociais têm Semantics/tooltip; Voltar recebe tooltip. Sobre/Vacinação/Saúde não receberam redesign sem referência.
- Referências Figma: arquivo p5Mv2Ej6kbfkgCfePLJKPr; Login 2564:1191, Cadastro 2564:473, Endereço 2566:230, Cadastro Pet 2577:451, Boas-vindas 2564:711, Pets 2564:616, Escolha 2629:4030, Serviços 2564:398, Convênio 2564:438, Agenda 2576:323, Novo Agendamento 2629:3780, Configurações SETTINGS_PAGE_2 2564:968. Medidas confirmadas na comparação anterior foram reutilizadas; o MCP permaneceu limitado pela quota Starter, então a comparação final de Login/Pets/Agenda foi feita na interface REAL do Figma. Sem alegação de leitura nova de todas as propriedades por MCP.
- Limitações visuais: Glass não reproduzido exatamente; raster da pata dimensionado pela proporção visível da exportação existente, sem copiar cegamente sua caixa de nó. Restam pequenos espaçamentos, efeitos/traços e detalhes da faixa de data. Fontes locais incluem Bold; estilos Medium solicitados são declarados, mas o peso físico 500 não está incluído e pode usar a variante disponível. Nenhum download de fontes/assets/dependências ou persistência de fotos.
- Validação final: flutter test 94 aprovados, 1 skip Web esperado, 0 falhas; inclui 10 regressões novas e suítes anteriores de navegação, horário, IDs e persistência. flutter analyze: 0 error, 0 warning, 29 infos preexistentes fora desta rodada (retorno 1). flutter build web aprovado com dry run Wasm. git diff --check aprovado.
- Manual Web em origem isolada 127.0.0.1:8769: dez telas solicitadas em 390x844; Login/Cadastro Pet/Pets/Nova Consulta/Agenda em 320x640; Login/Pets/Agenda em 1280x800. CPF 123 e telefone 119 bloqueados independentemente; valores completos avançaram. Cão/gato fictícios cadastrados sem círculo; consultas reais criadas para o cão em 10/11 e depois 05/10; Histórico mostrou outubro primeiro e Agenda abriu no mês escolhido. Saúde tem aviso e delimitação. Em 320, Cadastre-se e último pet acessíveis por rolagem, + permanece externo. Sem overflow ou erro visível observado; não foi auditoria geral.
- Comparação final dos pontos críticos: LOGIN—PATA CORRIGIDA; PETS—ÍCONES CORRIGIDOS; AGENDA DESKTOP CORRIGIDA. Fidelidade absoluta de efeitos/Medium ainda limitada. Este lote continua NÃO publicado e exige revisão do usuário; nenhuma etapa seguinte foi iniciada.


## Consistência final de imagem de pets/assets — NÃO publicado (04/10/2026)

- Branch kelvin; HEAD e75ea44e099efa0764072016b9fc4d9f2b8e90a9. Todo o lote anterior preservado; .gitignore e pubspec/lockfile sem alteração nesta rodada. Sem commit, push, merge, configuração ou teste nativo.
- Identidade oficial centralizada em lib/core/utils/pet_images.dart: cachorro usa assets/imagens/figma/cachorroegatopng-2.png; gato usa assets/imagens/figma/cachorroegatopng-3.png. Nomes físicos mantidos para compatibilidade com dados salvos; os nomes das constantes são inequívocos (dog/cat).
- PetAvatar prioriza imagem válida existente. Placeholders/caminhos legados e falha de leitura usam a espécie informada pelo PetModel. Espécie desconhecida recebe representação neutra “?”. Não há troca automática cachorro/gato baseada no nome do arquivo. Os caminhos legados não são alterados ao renderizar.
- Listas Pets/Escolha mantêm silhueta direta 32x36 sem decoração individual. Demais contextos preservam recorte circular/arredondado; silhueta usa contain com margem interna para evitar corte do corpo. Imagem inválida também respeita o contexto da lista, sem cair em círculo ou logo.
- Cadastro cria PetModel com caminho oficial; os exemplos iniciais usam constantes oficiais sem alterar IDs. Editor mantém a imagem ao renomear e preserva imagem personalizada ao trocar espécie; somente placeholder muda para o fallback da nova espécie. Sem persistência nova de fotos nem mudança de schema/regras de horário/rotas.
- Superfícies ativas conferidas: Pets, Escolha, Detalhes/PetSummary, Saúde, Carteira de vacinação, Serviços, Convênio, Novo Agendamento e resumo Próximo Agendamento em Agendamentos. Editor/modal não exibe avatar. Agenda, próximo evento de Detalhes e Histórico de Configurações não têm avatar de pet; não foi acrescentado. Os ícones de campo/menu/pata de navegação não são fallbacks e foram preservados. Telas legadas PetScreen/PetsScreen/VHBadge não foram reformadas.
- Removidos somente seis exports byte a byte idênticos aos oficiais: cachorroegatopng-2-2.png, cachorroegatopng-2-3.png, cachorroegatopng-2-4.png, cachorroegatopng-3-2.png, cachorroegatopng-3-3.png e cachorroegatopng-3-4.png, todos em assets/imagens/figma/. Zero referências literais de carga em lib/test/pubspec; nenhum carregamento dinâmico desses arquivos nas rotas ativas. Snapshots antigos com esses nomes são reconhecidos como placeholder e resolvidos pela espécie, sem solicitar o arquivo excluído. Ausentes também no build final.
- Preservados deliberadamente: cabeças img_cachorroegato_png.png/img_cachorroegato_png_36x32.png (referências em VHBadge, ImageConstant e PetsTheme/legado); padrão de patas img_image_2.png e placeholder image_not_found.png (constantes/loaders genéricos); exports de patas de bottom nav e outros elementos Figma incertos; logos, pata do Login, sociais, veterinária, Perfil, Serviços e Convênio. Não houve limpeza genérica.
- Testes: 9 novas regressões de espécie/placeholders, ambas as espécies em 9 superfícies e 2 viewports, prioridade de imagem válida, imagem inválida sem círculo na lista, neutro desconhecido, renomeação por ID e preservação de imagem ao editar espécie. Teste legado do Passo 3A passou a fornecer a espécie real, mantendo proteção de contraste e não mutação. Suíte completa: 103 aprovados, 1 skip Web esperado, 0 falhas. Analyze: 0 error/0 warning/29 infos preexistentes, retorno 1. Build Web aprovado em 101,6s, dry run Wasm aprovado. git diff --check aprovado.
- Manual do build final em origem isolada 127.0.0.1:8769, dados fictícios existentes TesteFinalCao/TesteFinalGato sem fotos: silhuetas corretas em todas as superfícies acima, em 390x844 e 320x640. Círculos intencionais mantidos; lista rolável alcança último pet; nenhum corte/overflow/deslocamento causado pelo avatar observado. Modal de edição, Agenda e Histórico conferidos sem alteração. Aviso Saúde mantido e ordem outubro/novembro do Histórico preservada. Console warn/error vazio durante o percurso: sem 404/Unable to load asset/exceção de imagem observados. Prioridade de imagem válida e erro de imagem foram validados automaticamente; não foi adicionado upload de fotos.
- Evidências e inventário em outputs/lote-assets do chat. Referência visual oficial continua a aprovada no Figma PETS_PAGE 2564:616; não foi reaberta a discussão sobre halo nem redesenhadas telas. Lote ainda NÃO publicado; tarefa encerrada aguardando revisão antes de qualquer commit.

## Último lote de acabamento — NÃO publicado (04/10/2026)

- Resolvidas as três pendências da auditoria: publicação posterior do Passo 4B explicitada sem apagar histórico; helper morto `loginPawScaleForWidth` removido e substituído no teste pela tela Login real em 320/390; helper residual `isAvailableTime` removido. `isFutureAppointmentTime` é consumido pelo seletor, pela validação de fim e pela gravação final, sem duplicar a regra ou alterar eventos antigos.
- `PetSummary` é a base de identidade por ID: compacta em Serviços/Convênio/Novo Agendamento, média em Saúde/Vacinação/Agendamentos e detalhada expansível em Detalhes. Nome marrom, espécie · raça, fundo rosa suave; dados reais de idade/peso/sexo/nascimento/castração quando aplicáveis. Foto prevalece sobre a silhueta, sem trocar o ID ao editar ou renomear.
- `photo_picker.dart` extrai o mesmo mecanismo galeria/câmera do Perfil. `pet_photo.dart` prepara PNG local com lado maior de até 256 px, rejeita entrada maior que 5 MB, limita cada foto a 180.000 caracteres base64 e o conjunto a 1.500.000. O campo opcional `photoBase64` segue no snapshot JSON/schema 1 do Passo 4B; snapshots antigos continuam legíveis. Web usa `MemoryImage`, sem `FileImage`, caminho de arquivo ou URL blob persistida. Não há backend nem dependência nova; `pubspec.yaml`/lockfile permaneceram iguais ao início desta rodada.
- Corrigida durante o teste real Web a leitura de `ImageDescriptor.width/height`, não suportada para imagens codificadas no navegador. A miniatura agora lê dimensões de um frame decodificado por `instantiateImageCodec`. Cadastro, editor e câmera em Detalhes funcionaram com PNGs fictícios; fotos reapareceram após refresh/reabertura. Limites são conservadores, não garantia de quota: se a gravação falhar, a UI informa que os dados/foto permaneceram somente na sessão. Fotos inválidas no snapshot caem no fallback sem descartar os demais dados.
- Cadastro e editor usam `PetForm`: foto/câmera, nome, espécie, Sexo/Peso lado a lado, nascimento, raça autocomplete e ações. Coluna compacta sem scroll normal em 390×844/320×640; scroll de contingência somente com teclado, validação ou janela excepcionalmente curta. Rótulos compactos evitam truncar Sexo. Seletores de espécie/sexo e gênero do cliente são overlays ancorados abaixo do campo, uma lista por vez, seta animada, fechamento por escolha/segundo toque; Outro continua com descrição customizada. Nenhum diálogo central para essas escolhas.
- Pets/Escolha aumentam a separação horizontal imagem/nome e mantêm silhuetas oficiais diretas 32×36 sem círculo individual. Fotos próprias recebem o recorte apropriado. Detalhes mantém ações, adiciona câmera pequena no avatar e expõe campos estruturados ao expandir.
- Saúde e Vacinação separam identidade, resumo e exemplos: badge discreto, Vermifugação por extenso, peso real preservado, cards leves e cores semânticas pontuais. Contagem de Vacinação é derivada dos dados, incluindo singular. Serviços junta categoria/subitens numa superfície contínua; Convênio mantém avanço direto sem radio/Continuar. Novo Agendamento tem bloco de detalhes e remove o nome redundante, mantendo pílulas, confirmação e regras de horário.
- Agendamentos tem próximo evento compacto/clicável pela data e estado vazio discreto; cada mock é identificado como Demonstração. `AppointmentCard` é compartilhado com Histórico de Configurações, agora bottom sheet com 85% da altura, lista interna rolável e Fechar. Ordem cronológica real preservada. Faixa da Agenda ficou quase branca/rosa suave mantendo calendário, sobreposição e navegação por data. Sua cor segue a direção autorizada pelo usuário, não uma nova medição do Figma; MCP continuou bloqueado pela quota.
- Validação final: `flutter test` **115 aprovados, 1 skip Web esperado, 0 falhas**; `flutter analyze` **0 errors, 0 warnings, 29 infos preexistentes** (retorno 1 pelos infos); `flutter build web` aprovado em **122,6 s**, dry run Wasm aprovado; `git diff --check` aprovado. Doze regressões novas cobrem foto/snapshot antigo/ID/renomeação/rejeição/MemoryImage/picker, formulários e seletores, gênero Outro e superfícies críticas em 320; testes anteriores foram adaptados mantendo suas proteções de navegação, horários, histórico e dados.
- Manual do build em origem isolada `127.0.0.1:8770`, sem modificar dados da origem anterior: Cadastro, Editar, Detalhes, Saúde, Vacinação, Serviços, Convênio, Novo Agendamento, Agendamentos, Histórico e Agenda em 390×844; formulários, seletores, Detalhes, Saúde, Agendamentos e Agenda em 320×640. Cadastro/troca/renomeação de fotos, fallback de espécies, consulta real fictícia e vínculo, refresh completo e fechamento/reabertura da aba conferidos. Ações e conteúdos finais não ficaram cobertos pela barra inferior; sem overflow/erro visível no percurso final. Console warn/error final vazio. Evidências e relatório em `outputs/acabamento-final` do chat.
- Limitações reais: seleção manual usou ilustrações PNG existentes como arquivos fictícios; JPEG/HEIC, câmera/permissões físicas e aplicativos nativos não foram validados. Armazenamento continua local por origem, sujeito à limpeza/quota do navegador e sem criptografia/backup/sincronização novos. Fidelidade absoluta ao Figma, Glass e peso físico Medium continuam com as limitações históricas. Nenhuma nova etapa iniciada; acabamento encerrado para nova auditoria pré-commit do usuário.
