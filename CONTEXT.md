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

## Problema preexistente no Flutter Web

Em `lib/pages/perfil_page.dart`, o avatar usa `Image.file(_foto!, ...)` quando `_foto` não é nula. Esse caminho falha no Flutter Web com a mensagem `Image.file is not supported on Flutter Web`.

A foto pode vir de `VetRepository.clientPhotoPath` ou da seleção via `image_picker`. O teste atual de perfil não cobre esse caminho com foto carregada no navegador. O problema está apenas documentado e não foi corrigido nesta etapa.

## Preservação e próximos passos

- Manter mudanças pequenas e limitadas ao objetivo visual; não fazer limpeza de lint ou refatoração geral.
- O escopo de código do Passo 1 é `lib/main.dart`, `lib/theme.dart`, `lib/theme/*`, `lib/widgets.dart` e `lib/widgets/vet_bottom_nav.dart`; alterar `pubspec.yaml` somente se necessário. Mudanças em outras áreas precisam de autorização.
- Preservar mudanças locais do usuário. A alteração preexistente em `.gitignore` para `.widget_preview/` pertence ao usuário e deve ficar fora do commit do Passo 1.
- Não aplicar automaticamente stashes ou branches de backup antigos.
- Quando o acesso ao Figma estiver disponível, conferir o tema global e a barra inferior contra os nós e screenshots reais, incluindo as cinco abas e a área segura mobile.
- Tratar a incompatibilidade de foto no Flutter Web em tarefa separada, após autorização.
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
- Próximo passo: conferir visualmente Pets e Perfil em dispositivo mobile e, quando o MCP estiver disponível, comparar com o Figma antes de autorizar a publicação desta etapa.

### Correção compartilhada de `VHHeader`

- Em `lib/widgets.dart`, a caixa inferior arredondada, sua decoração e sombra só são renderizadas quando `bottom != null`.
- Sem `bottom`, o cabeçalho deixa de reservar a altura dessa área: tem 64 px com título e botões, ou 80 px quando também existe subtítulo. Essas alturas são escolhas de layout locais; não são medidas confirmadas do Figma.
- Com `bottom`, permanecem a altura original de 125 px, posição, dimensões, decoração e conteúdo da caixa. Serviços e Convênio fornecem `_PetTypeTag` nesse slot e conservam o layout anterior.
- Os consumidores sem `bottom` corrigidos são `SobreScreen`, `ChatScreen` (Whatsapp), `ConfigScreen`, `EscolhaPetScreen` e as implementações legadas `PetsScreen`, `PetScreen`, `EditPetScreen` e `PerfilScreen`.
- `PetsPage` e `PerfilPage` têm cabeçalhos próprios. A remoção do bloco vazio de `PetsPage` continua necessária e foi mantida; a correção de `VHHeader` não substitui esse ajuste. Também foram preservados os ícones de animais sem círculo e o avatar plano de Perfil.
- Rotas, callbacks, lógica de negócio e navegação permanecem inalterados. Nenhum arquivo de outras telas foi editado para aplicar a correção compartilhada.
