# Integração entre Cliente e Veterinária Gabriela

Auditoria de 21/11/2026. Revisões examinadas: [liminha em 7736126](https://github.com/LEanMist/flutter_vethome/tree/7736126c26c22e71d6c191ad569eaaa6a734c32c) e [leandro em 3b4e0e6](https://github.com/LEanMist/flutter_vethome/tree/3b4e0e6d0704d9e0016ed61564057d8a49a6b937). O escopo é o repositório Flutter. Uma decisão da equipe do servidor pode existir fora dele e ainda precisar de registro aqui.

## O que o aplicativo faz hoje

| Área | Evidência no código | Alcance |
| --- | --- | --- |
| Cliente em `liminha` | [Login](../lib/pages/login_page.dart), [VetRepository.authenticate](../lib/data/vet_repository.dart) e [armazenamento](../lib/data/local_storage.dart) | Um perfil por instalação. Valida formato do e-mail, senha não vazia com ao menos seis caracteres e compatibilidade com o e-mail local quando preenchido. A senha digitada não é comparada a uma senha cadastrada. “Lembre-se de mim” guarda o e-mail. O snapshot não contém senha ou identidade de sessão. |
| Veterinária em `liminha` | [Rotas](../lib/routes/app_routes.dart), [perfil local](../lib/data/gabriela_profile_repository.dart) e [configurações](../lib/pages/gabriela/gabriela_area_page.dart) | O login demonstrativo abre a área sem credenciais. As abas aceitam rota direta, sair volta ao login. Nome e foto editáveis identificam o perfil visual. Nenhum desses passos emite, valida ou revoga sessão de servidor. |
| Agenda e histórico em `liminha` | [Agenda Gabriela](../lib/pages/gabriela/gabriela_agenda_tab.dart), [cartão veterinário](../lib/pages/gabriela/gabriela_appointment.dart) e [agendamentos do Cliente](../lib/pages/agendamentos_page.dart) | Gabriela abre em hoje, tem exemplos identificados de 10/03/2026 e histórico vazio de atendimentos verificados. O histórico da tela do Cliente agrupa eventos pelo tempo. `realAppointments(petId)` devolve apenas agendamentos locais de um pet existente. |
| Usuários em `leandro` | [Usuario][usuario], [UsuarioRepository][usuarios] e [login][login-leandro] | O login compara senha em memória por e-mail ou nome e passa o ID à próxima tela. A implementação inclui conta de teste e senhas em memória. O ID é local, o modelo não contém papel nem sessão. |
| Consultas em `leandro` | [Agendamento][agendamento], [AgendamentoRepository][agendamentos], [seleção do paciente][selecao] e [PetRepository][pets] | Interface assíncrona e implementação em memória. A tela usa o primeiro usuário se faltar `usuarioId` e lista pets via `findAll()`. O [modelo Pet][pet] não associa o animal a um tutor. Os filtros por usuário e por pet apenas selecionam registros. |

## Transporte confirmado no cliente Flutter

O [cliente HTTP](../lib/data/remote/vethome_api_client.dart) contém três operações experimentais com requisições JSON. Os [testes de transporte](../test/vethome_api_client_test.dart) usam um cliente HTTP controlado. O comportamento abaixo foi confirmado no código Flutter. A equipe ainda precisa validar o contrato do servidor.

| Operação observada | Campos enviados pelo DTO |
| --- | --- |
| `POST cliente` | [nome, dataNascimento, cpf, telefone, email, senha](../lib/data/remote/contracts/client_create_request.dart) |
| `POST cliente/endereco` | [cep, logradouro, complemento, bairro, cidade, numero, cpfCliente](../lib/data/remote/contracts/address_create_request.dart) |
| `POST cliente/pet` | [nome, dataNasc, especie, raca, peso, convenio, cpfCliente](../lib/data/remote/contracts/pet_create_request.dart) |

A [configuração](../lib/data/remote/api_config.dart) exige origem HTTPS via `VETHOME_API_BASE_URL`. O transporte aceita 200/201, retorna `void`, ignora o corpo de sucesso e envia apenas o cabeçalho JSON explícito. [ApiException](../lib/data/remote/api_exception.dart) distingue configuração, rede, timeout e erro HTTP, mantendo o código HTTP sem reter o corpo. Os contratos de login, sessão, consulta, histórico e chat permanecem em aberto. Os campos de CPF observados no cadastro não comprovam quem está fazendo uma requisição.

## Comparação dos agendamentos

| Informação | `liminha` | `leandro` |
| --- | --- | --- |
| Consulta | Sem ID de consulta. A remoção local compara a instância do objeto. | `id` opcional até salvar. O repositório em memória gera ID local ou reutiliza o fornecido. |
| Tutor, pet e veterinária | `petId` está no JSON e na chave do mapa, externo ao objeto. Há um único perfil Cliente. `veterinario` é texto. | `usuarioId` acompanha quem solicita e `petId` indica o animal escolhido. O repositório não verifica titularidade, existência das referências nem atribuição a uma veterinária. Falta um ID da profissional. |
| Serviços, plano e endereço | `tipo` é texto. Nova Consulta forma `local` com “VetHome ·” e o plano. Esse campo não comprova endereço de visita. `descricao` é opcional. | Lista de serviços com ID, categoria e nome. Convênio enumerado, endereço e descrição em texto. |
| Data e duração | `data` inclui a hora. `endDate` é opcional. A checagem de conflito assume uma hora para registro antigo sem fim. | Dia normalizado, hora `HH:mm`, `criadoEm`. Sem fim, duração ou política de fuso no contrato compartilhado. |
| Conflito | A tela confere sobreposição por pet ou nome normalizado da veterinária no dispositivo. Intervalos adjacentes são aceitos. | O repositório bloqueia mesmo dia e horário inicial de qualquer registro não cancelado, exceto o próprio ID. Não diferencia veterinárias nem detecta sobreposição com início diferente. |
| Edição e exclusão | Editar pet preserva o ID. Remover pet apaga suas consultas locais. Excluir agendamento remove o registro. | `save` substitui pelo ID. `delete` remove do mapa. Não há política conjunta de integridade, retenção ou autoria. |

Fontes das regras locais: [modelo e serialização](../lib/models/vet_models.dart), [repositório](../lib/data/vet_repository.dart), [gravação do agendamento](../lib/pages/nova_consulta_page.dart) e [repositório de referência][agendamentos].

Na tela Nova Consulta de `liminha`, o nome da profissional vem de uma constante de demonstração. Na finalização de `leandro`, a interface exige a seleção do endereço e copia sua descrição para a consulta. A troca posterior do endereço cadastrado não atualiza esse texto automaticamente. [Finalização em leandro][finalizacao]

## Status e significado do histórico

Ao terminar a marcação, a tela de `leandro` informa “Agendamento concluído” ao tutor. O rascunho finalizado cria o objeto no estado padrão `solicitado`. A mensagem descreve o término do cadastro da reserva. Ela não registra conclusão clínica. [Tela de agendamento][selecao] · [Modelo][agendamento]

**Fato observado.** Em `liminha`, o leitor do snapshot exige um dos dois nomes do enum. Em `leandro`, o leitor assume `solicitado` quando o campo falta e rejeita nomes desconhecidos. O repositório aceita salvar o status do objeto sem matriz de transições ou verificação de autor. A validação do objeto rejeita dias passados a cada `save`, inclusive se apenas o status mudou. Um atendimento de ontem pode ficar impossível de concluir por esse caminho.

| Valor local | Valor em `leandro` | Proposta para leitura futura, sujeita a aprovação |
| --- | --- | --- |
| `pendente` | `solicitado` | Candidatos a equivalência. Confirmar se toda pendência representa solicitação já recebida. Preservar a origem e o valor bruto. |
| `confirmado` | `confirmado` | Candidato a agendamento aceito. A confirmação da marcação não comprova o atendimento. |
| Sem equivalente | `cancelado` | Exibir como cancelamento quando vier de fonte autorizada. Exclusão local não comprova cancelamento no servidor. |
| Sem equivalente | `concluido` | Incluir no histórico clínico mediante conclusão registrada pelo servidor e autorização de leitura. |
| Ausente ou desconhecido no transporte futuro | Sem equivalência acordada | Preservar o valor na camada de transporte, impedir ações dependentes do estado e distinguir incompatibilidade de lista vazia. |

**Proposta para discussão.** Submeter à equipe as passagens solicitação → confirmação, solicitação/confirmação → cancelamento e confirmação → conclusão. Definir para cada passagem ator autorizado, pré-condições, prazo, possibilidade de correção e resposta à repetição. A permissão de concluir e as permissões de confirmar ou cancelar pela veterinária continuam pendentes. Separar validação de criação/remarcação da validação de conclusão. O horário passar, por si só, não altera o estado.

**Evidência proposta para o histórico.** Registrar a mudança de estado no servidor com consulta, autor autenticado, instante do servidor e versão. Responder com o estado efetivamente persistido. O histórico veterinário lê somente conclusões autorizadas para a profissional e distingue resultado vazio, sessão expirada e falha de leitura. Uma escrita interrompida exige reconciliação antes de indicar sucesso ou repetir a operação.

## Relacionamentos, autorização e sessão a pactuar

| Vínculo ou ação | Regra proposta ao backend | Decisão pendente |
| --- | --- | --- |
| Conta → perfil | O servidor resolve a conta, o papel e o ID do perfil a partir de sessão válida. O cadastro público continua restrito ao Cliente. | Como a equipe provisiona, vincula e desativa uma conta veterinária? Uma conta pode ter ambos os papéis? |
| Consulta → tutor → pet | A consulta tem ID estável, tutor e pet por ID. O servidor valida a relação de titularidade válida no momento da marcação e o escopo de leitura atual. | Quem mantém a titularidade? Como representar transferência, exclusão e acesso ao histórico anterior? |
| Consulta → veterinária | Atribuição explícita a um perfil profissional, verificada em lista, detalhe e cada alteração. Consulta sem atribuição fica fora da agenda pessoal. | Quem atribui ou reatribui? Quando a profissional anterior perde acesso? |
| Leitura e alterações | Tutor acessa apenas suas consultas. A profissional acessa somente as atribuídas a ela, com os campos necessários. O servidor verifica a ação e os vínculos inclusive quando recebe um ID válido. | Quais campos cada papel pode consultar ou mudar? Quais regras valem para endereço, descrição e dados do pet após o atendimento? |
| Agenda e concorrência | Validar sobreposição de intervalos no servidor por ID da profissional e do pet, na mesma transação da reserva. Validar versão nas mudanças de estado. | Qual fuso, duração e política de horários adjacentes? Qual resposta para concorrência ou versão desatualizada? |
| Histórico e exclusões | Preservar a autoria da conclusão e as referências históricas após mudança de nome/endereço. Definir arquivamento, anonimização ou restrição de exclusão conforme a política aprovada. | Quais campos são fotografia do momento da visita, quais vêm do cadastro atual e por quanto tempo ficam disponíveis? |

**Contrato de sessão solicitado.** Especificar emissão, transporte e armazenamento para Flutter mobile e web, validade, renovação, revogação e saída em todos os dispositivos aplicáveis. Fornecer exemplos sanitizados de sucesso, credenciais inválidas, sessão expirada/revogada, papel sem acesso, registro inacessível e conflito. Confirmar os códigos e corpos antes de vincular a UI a 401, 403 ou outra convenção. A resposta de erro deve permitir tratar o caso sem revelar dados de outro tutor ou repetir credenciais em logs.

**Proteção de rotas proposta.** Ao iniciar, retomar ou abrir link direto para uma aba real, verificar a sessão e o papel antes de mostrar dados. Enquanto a verificação estiver pendente, aguardar. Ao expirar, tentar a renovação prevista no contrato ou voltar ao login. Ao sair, revogar conforme contrato e descartar dados em memória e caches da sessão. A falha de autorização não deve abrir uma demonstração como se fosse a agenda real. Cada requisição do serviço continua sujeita à autorização pelo servidor. [Referência de segurança da OWASP](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html)

## Preparação local e compatibilidade

1. Manter o leitor e o gravador de `vethome.state.v1`. A versão 1 verifica unicidade dos pets, referência de cada consulta e status conhecido. Não gravar valores do servidor nesse enum. Manter disponíveis localmente consultas antigas, inclusive sem `endDate`. [Snapshot](../lib/data/local_storage.dart)
2. Quando houver exemplos aprovados de requisição e resposta, definir DTOs de transporte e um mapeador de status fora dos modelos de persistência. O modelo de exibição veterinário pode receber uma projeção com tutor, paciente e campos opcionais. Os cartões fictícios e o repositório local do Cliente continuam com origens distintas.
3. Reutilizar o padrão de interface injetável de [AgendamentoRepository][agendamentos]. Para a área real, prever operações de leitura de agenda por período, detalhe e histórico limitadas à sessão. A UI deve distinguir dado, vazio, acesso recusado e falha recuperável. A interface pública da tela não precisa de uma listagem geral de usuários, pets ou consultas. Os nomes e assinaturas dependem dos contratos de exemplo.
4. Não importar automaticamente o snapshot para uma conta. Falta identidade remota de tutor, veterinária e consulta. Se houver migração aprovada, definir versão separada, confirmação de titularidade, correspondência de IDs emitidos pelo servidor e registro de itens já importados. Preservar o original até verificar a leitura da nova versão. Repetir uma migração interrompida não pode duplicar reservas. Excluir fixtures do processo.
5. Testar os adaptadores com repositórios falsos e respostas sanitizadas antes de ligar telas. Cobrir dois tutores e duas veterinárias com nomes iguais, troca de conta com consulta em andamento, pet de outro tutor, consulta reatribuída, expiração, estado desconhecido, conclusão tardia, cancelamento, tentativas concorrentes, erro de gravação e snapshot v1. O teste do serviço deve provar a recusa, inclusive na abertura direta de detalhes. A suíte Flutter cobre a reação da interface.

Já existem testes de [isolamento das rotas](../test/veterinarian_login_separation_test.dart), [agenda da Gabriela](../test/gabriela_agenda_test.dart), [conflitos locais de horário](../test/nova_consulta_time_validation_test.dart) e [proteção do snapshot](../test/local_storage_protection_test.dart). O protocolo de sessão, os DTOs de agenda e uma migração executável dependem das decisões descritas acima.

## Chat e suporte

- **Chat entre contas.** A [lista demonstrativa](../lib/data/gabriela_demo_chat.dart) e a [tela de mensagens](../lib/pages/gabriela/gabriela_messages_tab.dart) mantêm conversas locais. O contrato real precisa definir ID da conversa, remetente obtido da sessão, destinatário e vínculo autorizado entre os participantes. Faltam persistência, envio, recebimento, ordem, prevenção de duplicação e significado dos estados de entrega. Identificar quem recebe uma mensagem e quem pode recuperar seu histórico após reatribuição.
- **Suporte institucional.** Solicitar à instituição o e-mail, o telefone e o responsável por validar e manter os canais. Os exemplos visuais da área Cliente não são fonte oficial. [Configurações da Gabriela](../lib/pages/gabriela/gabriela_area_page.dart)

## Ordem recomendada e critérios de avanço

1. **Identidade e sessão.** A equipe do backend entrega exemplos sanitizados de login, renovação, saída e acesso negado para ambos os papéis. Flutter e backend aprovam juntos as respostas a sessão expirada e a papel incorreto.
2. **Agenda somente leitura.** A equipe do banco confirma IDs, titularidade e atribuição. O backend apresenta lista por período e detalhe autorizados, incluindo um exemplo permitido, um acesso negado a outro perfil e um dia vazio. Só então ligar um adaptador da agenda real.
3. **Estados e histórico.** Aprovar matriz de transições, autor da conclusão, evidência persistida, fuso, conflito e efeito de exclusões. Validar conclusão de atendimento passado, repetição e concorrência antes de habilitar escrita ou histórico clínico.
4. **Legado, chat e suporte.** Decidir separadamente se haverá importação de dados locais. Integrar chat após aprovação de seu próprio contrato. Publicar contatos quando a instituição indicar os canais e seu responsável.

[usuario]: https://github.com/LEanMist/flutter_vethome/blob/3b4e0e6d0704d9e0016ed61564057d8a49a6b937/lib/models/usuario.dart
[usuarios]: https://github.com/LEanMist/flutter_vethome/blob/3b4e0e6d0704d9e0016ed61564057d8a49a6b937/lib/repositories/usuario_repository.dart
[login-leandro]: https://github.com/LEanMist/flutter_vethome/blob/3b4e0e6d0704d9e0016ed61564057d8a49a6b937/lib/pages/login_page.dart
[agendamento]: https://github.com/LEanMist/flutter_vethome/blob/3b4e0e6d0704d9e0016ed61564057d8a49a6b937/lib/models/agendamento.dart
[agendamentos]: https://github.com/LEanMist/flutter_vethome/blob/3b4e0e6d0704d9e0016ed61564057d8a49a6b937/lib/repositories/agendamento_repository.dart
[selecao]: https://github.com/LEanMist/flutter_vethome/blob/3b4e0e6d0704d9e0016ed61564057d8a49a6b937/lib/pages/agendamento_page.dart
[pets]: https://github.com/LEanMist/flutter_vethome/blob/3b4e0e6d0704d9e0016ed61564057d8a49a6b937/lib/repositories/pet_repository.dart
[pet]: https://github.com/LEanMist/flutter_vethome/blob/3b4e0e6d0704d9e0016ed61564057d8a49a6b937/lib/models/pet.dart
[finalizacao]: https://github.com/LEanMist/flutter_vethome/blob/3b4e0e6d0704d9e0016ed61564057d8a49a6b937/lib/pages/finalizar_agendamento_page.dart

## Auditoria de Nicolly em 23/11/2026

Revisão de leitura em [62679a4](https://github.com/LEanMist/flutter_vethome/tree/62679a45a089b720d9543cf22b216d1ab7f4d03e/lib). Há 34 commits exclusivos em relação a Kelvin, com ancestral comum em `743e3e9`. As operações abaixo foram verificadas no cliente Flutter. A equipe do servidor ainda precisa confirmar rotas, formatos e regras de acesso.

| Área | Implementação observada na Nicolly | Decisão para a integração |
| --- | --- | --- |
| Cadastro e login | `ClienteService` envia nome, nascimento, CPF, telefone, e-mail e senha a `POST /cliente`. O login envia e-mail e senha a `POST /login`, distingue 401 e limita a espera a 10 s. | Manter o transporte experimental existente. Confirmar o DTO de resposta, a autenticação das requisições posteriores, validade da sessão, papel e logout. |
| Sessão | `Session` mantém campos estáticos em memória e considera um CPF preenchido suficiente para indicar login local. | CPF identifica o cadastro. O servidor precisa verificar titularidade e emitir a identidade autenticada. O login demonstrativo da Gabriela continua separado. |
| Pets | `GET /pet?cpfCliente=…&size=100` lista pets e `POST /pet` cadastra. O transporte experimental de Liminha usa `POST /cliente/pet`. | Confirmar a rota canônica, paginação, IDs retornados, espécies e como associar IDs locais aos do servidor. |
| Endereços | Lista por CPF, cadastra com POST, edita com PUT em `/endereco` e exclui por ID numérico. A lista exibida usa cache em memória. O contrato experimental de Liminha usa `/cliente/endereco`. | Preservar o snapshot e os endereços locais existentes. Pactuar paginação, atualização, confirmação de escrita e mapeamento de IDs. |
| Horários | `GET /consulta/horarios-disponiveis?data=AAAA-MM-DD` espera uma lista de strings HH:mm. Nova Consulta consulta a disponibilidade e oferece seleção de endereço pelo diálogo. | Confirmar fuso, duração, profissional, indisponibilidade e conflito concorrente no ato de criar a reserva. |
| Consulta | `POST /consulta` requer ID de pet como texto e ID numérico de endereço. Envia CPF, serviços, convênio, data, início, fim e descrição. Também envia aliases para data, horário e descrição. A tela não preenche o horário final. | Definir tipos, campos obrigatórios, formato da seleção múltipla, resposta com ID, estado e regras para repetição de uma requisição interrompida. |
| Configuração e erros | `API_URL` possui defaults HTTP de desenvolvimento. Há serviços que incluem o corpo bruto no erro, outros leem `mensagem`. Consulta aceita 200/201. | Preservar `VETHOME_API_BASE_URL` com HTTPS e os erros tipados da Liminha. Confirmar respostas de erro e expor somente mensagens apropriadas ao usuário. |

O commit `62679a4` integra a escolha do endereço à tela de consulta. Sua UI depende dos endereços do cliente e de um ID aceito pelo servidor. A seleção local de Kelvin atende ao agendamento demonstrativo. Nenhuma chamada a servidor foi feita nesta auditoria, e `lib.zip` ficou fora da integração.
