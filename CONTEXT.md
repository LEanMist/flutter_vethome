# VetHome — contexto para continuar o projeto

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

- Implementado localmente na branch `kelvin`, sem commit ou push nesta etapa. As três pendências de Login, título e foto Web registradas no Passo 3A foram tratadas aqui.
- `lib/pages/login_page.dart`: a escala da decoração da pata agora considera a largura disponível, incluindo os dedos laterais posicionados fora da caixa, suas rotações e sombras. Elementos, campos, botões, textos, autenticação e rolagem permanecem iguais. Validado visualmente em 320 × 480, 320 × 640 e 390 × 844, sem cortes laterais problemáticos ou overflow vertical. O cálculo é uma escolha local, não uma medida do Figma.
- `lib/widgets/vet_header.dart`: o título completo mantém fonte/texto existentes, com `FittedBox` e `BoxFit.scaleDown` apenas quando a largura entre os botões não é suficiente. Voltar, diagnóstico, slot inferior e ausência da caixa vazia permanecem preservados. Novo agendamento foi conferido em larguras de 320 e 390 px; Detalhes, Editar pet, Saúde, Vacinação e Agendamentos também foram conferidos.
- `lib/pages/perfil_page.dart` e `lib/data/vet_repository.dart`: adaptação mínima para bytes no navegador, descrita acima. O picker, avatar padrão, moldura, dimensões e ações do Perfil foram mantidos. Nenhuma dependência ou asset novo foi adicionado.
- `test/vet_home_step3b_test.dart`: regressões para escala da decoração do Login, títulos completos/botões em dois tamanhos, avatar padrão, restauração em memória no Web sem `FileImage`, manutenção de `FileImage` nativo e seleção nativa via picker simulado. Os testes específicos de cada plataforma são executados somente nela.
- Validação: oito testes existentes, cinco do Passo 3A e cinco do Passo 3B passando no runner nativo; o teste exclusivo do Web é ignorado nesse runner. Análise dos arquivos alterados sem ocorrências e `git diff --check` aprovado. No app Web, a seleção real pelo `image_picker`, o avatar padrão e a manutenção da foto ao reabrir Perfil foram conferidos por capturas. A execução da suíte pelo runner Chrome ficou bloqueada antes dos testes por erros 404 nos arquivos locais do motor gráfico (CanvasKit e skwasm); isso não impediu executar e validar o app no navegador.
- Limitações: cache da foto é apenas da sessão, como os demais dados do repositório de exemplo; câmera e permissões precisam de validação em dispositivos físicos. Fidelidade exata ao Figma permanece pendente pelo limite do MCP. Não foram alterados Pets, Escolha de Pet, paleta, fontes globais, sombras ou formulários.
