# Preparação para demonstração

## Identidade e distribuição

| Plataforma | Nome e identificação | Ícone e inicialização | Build e permissões |
| --- | --- | --- | --- |
| Android | Rótulo VetHome. `applicationId` e namespace mantidos em `com.example.flutter_vethome`. | Ícones e fundo de abertura nativos do modelo Flutter. Em seguida, o aplicativo exibe a Splash VetHome. | O manifesto do app declara `INTERNET`. A seleção de fotos usa o seletor do sistema, sem permissões amplas de câmera ou galeria no manifesto do app. O build debug usa a chave padrão do Android. Release aguarda assinatura aprovada pela equipe. |
| Windows | Janela e metadados de produto VetHome. Executável `flutter_vethome.exe` e nome interno preservados. O campo `CompanyName` ainda contém `com.example`. | Ícone do modelo Flutter. A abertura no aplicativo usa a Splash Flutter da VetHome. | Bundle x64 de depuração. O manifesto declara compatibilidade com Windows 10/11 e suporte a DPI por monitor. |
| Web | Título no HTML e nome no manifesto de instalação `VetHome \| Cuidado veterinário`. Nome curto, metadado para iOS e título em execução `VetHome`. | Favicon e ícones do modelo Flutter, fundo rosa declarado no manifesto e Splash Flutter VetHome. | Build de produção com CanvasKit e fontes servidos junto ao aplicativo. |

A versão do projeto continua em `1.0.0+1`. O Roboto usado como fallback do motor Web é distribuído em `assets/fonts/` com a licença Apache 2.0. O build Web precisa estar em uma origem acessível, por exemplo, um servidor local. A validação com internet bloqueada confirma a abertura com recursos locais. Abrir uma URL remota sem acesso ao servidor depende da estratégia de hospedagem e cache.

## GitHub Actions

O workflow [Qualidade Flutter](../.github/workflows/qualidade.yml) usa Flutter 3.50.1 e valida o lockfile. Ele roda em pushes para `liminha` que alteram código, testes, assets ou configuração de build. No Ubuntu, verifica a formatação dos arquivos Dart alterados, bloqueia diagnósticos de nível erro ou aviso, roda os testes no runner local e compila Web e APK debug. No Windows, compila o bundle x64 debug. Os jobs têm limites de 35 e 25 minutos. Os artefatos publicados em **Artifacts** ficam disponíveis por sete dias.

O Android usa Gradle 9.5.0, Android Gradle Plugin 9.3.1 e Kotlin 2.4.20, versões do modelo do Flutter 3.50.1. A distribuição binária do Gradle é verificada pelo SHA-256 do wrapper. A [primeira execução](https://github.com/LEanMist/flutter_vethome/actions/runs/45096953513) identificou o `sdkmanager` fora do `PATH`. A [segunda execução](https://github.com/LEanMist/flutter_vethome/actions/runs/45097586136) passou da preparação do SDK e identificou o Gradle anterior abaixo do mínimo aceito pelo Flutter.

## Evidências de validação

| Verificação | Resultado |
| --- | --- |
| Dependências | `flutter pub get --offline --enforce-lockfile` concluído com o cache local. O CI usa `flutter pub get --enforce-lockfile`. |
| Análise estática local | 0 erros, 0 avisos e 208 informações. |
| Suíte no runner local | 666 testes aprovados e 5 exclusivos da Web ignorados nesse runner. Inclui restauração de estado, falhas de gravação e recuperação, seleção de fotos, navegação e formulários responsivos com texto ampliado. |
| Build Web local | `flutter build web --no-pub --no-web-resources-cdn` concluído. O Chrome 157 abriu o Login em 390 × 844 com tráfego externo bloqueado, carregou CanvasKit e Roboto locais e registrou 36 recursos locais sem erros JavaScript ou respostas 404 no teste. |
| Android e Windows na máquina local | As duas tentativas pararam no download de artefatos do motor por falha de DNS de `storage.googleapis.com`. O `flutter doctor` também apontou ausência do SDK Android e do Visual Studio. |
| GitHub Actions | Na [execução do commit `3405386`](https://github.com/LEanMist/flutter_vethome/actions/runs/45098245007), passaram a análise, os testes no runner local e os builds Web, APK Android debug e Windows x64 debug. Os três artefatos foram gerados. |

### Widgets no Chrome

O Flutter 3.50.1 no Windows ainda apresenta o erro no caminho em que o runner serve o CanvasKit, registrado no [Flutter #192069](https://github.com/flutter/flutter/issues/192069). A tentativa com `flutter test --no-pub --platform chrome` e o teste do seletor de fotos ficou na inicialização do iframe. Uma cópia temporária do runner com o ajuste de CanvasKit permitiu executar sete testes focados no Chrome, incluindo os quatro casos de bloqueio de gravação Web e os três de opções de foto. Nos diagnósticos com a cópia temporária, as requisições diretas à fonte Montserrat Alternates e a um SVG da tela de serviços devolveram HTTP 404. Ao disponibilizar esses recursos na pasta de teste temporária, o servidor passou a devolver HTTP 200. Mesmo assim, `rootBundle.load` expirou para ambos, e `FontLoader.load` também expirou no teste da fonte. O runner também registrou a ausência de `assets/FontManifest.json` e uma tentativa de obter Roboto externamente. Os diagnósticos preservaram o SDK instalado e os timeouts da suíte. A aprovação da suíte completa de widgets no Chrome segue pendente.

### Experiência

A suíte automatizada cobre navegação entre abas durante edição, operações concorrentes, armazenamento indisponível, retomada após falha, redimensionamento e estados demonstrativos. Um teste local adicional, com retorno de cancelamento simulado pelo seletor, preservou a foto do pet já salva e não abriu mensagem de erro. Ainda falta validar os fluxos em dispositivos instalados, incluindo reabrir o aplicativo, usar o seletor nativo de fotos e verificar teclado e acessibilidade com as tecnologias assistivas do sistema.

## Checklist

- [x] Exibir VetHome no Android, Windows e Web.
- [x] Fixar a versão do Flutter e automatizar a validação em `liminha`.
- [x] Verificar localmente o build Web, a abertura com acesso externo bloqueado e a suíte no runner local.
- [x] Gerar os três artefatos de demonstração no GitHub Actions.
- [ ] Aprovar a suíte completa de widgets no Chrome.
- [ ] Instalar os bundles de demonstração e verificar persistência ao reabrir, fotos, teclado e acessibilidade em dispositivos.
- [ ] Definir e aprovar ícone, favicon, splash nativa, identificação definitiva de distribuição e assinatura de produção.
- [ ] Confirmar os contatos institucionais e os [contratos pendentes](integration_contracts_pending.md) para login único, agenda e histórico reais da Gabriela e chat entre contas.
