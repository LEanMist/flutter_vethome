# Persistir a foto do tutor

## Intenção

Manter a foto escolhida no Perfil depois de reiniciar ou recarregar o VetHome, com o mesmo resultado no Web e nas plataformas nativas. Hoje o Perfil mantém bytes/caminho apenas na sessão; o snapshot local já persiste fotos dos pets.

## Objetivos e limites

- Salvar uma miniatura PNG no snapshot local e restaurá-la ao inicializar o repositório.
- Reutilizar validação, redução de tamanho e limites já usados pelas fotos dos pets.
- Aceitar snapshots antigos sem o campo opcional, sem aumentar a versão do schema.
- Se a gravação falhar, manter a foto na sessão e avisar que ela não foi salva.
- Não persistir caminhos de arquivo, bytes brutos, senha ou dados na nuvem; não adicionar dependências.

## Abordagens consideradas

1. **Miniatura Base64 opcional no snapshot local (escolhida).** Reaproveita o formato PNG validado que já funciona para pets e permite restaurar a mesma foto no Web, Android e Windows. Consome parte do limite de armazenamento local, por isso a foto do tutor deve compartilhar o limite total das imagens.
2. **Persistir o caminho do arquivo.** É menor no snapshot nativo, mas caminhos locais não são portáveis e URLs temporárias do Web expiram; não atende a restauração uniforme.
3. **Manter somente na sessão.** Não muda a arquitetura, mas deixa sem solução a pendência de persistência da foto do tutor.

## Decisões de implementação

- Adicionar um campo opcional `photoBase64` ao `ClientData` dentro do snapshot `schemaVersion: 1`; ausência continua significando perfil sem foto.
- Usar `PetPhoto.choose` para obter a imagem normalizada e validada. Contabilizar a foto do tutor no mesmo limite total de 1.500.000 caracteres Base64 das fotos dos pets.
- Adicionar uma mutação do repositório que valide, salve e aguarde a fila local. Um erro de gravação não deve descartar a foto na memória, seguindo o comportamento existente para fotos de pets.
- Restaurar a miniatura como bytes para `Image.memory` em qualquer plataforma. Caminhos/bytes legados podem continuar como fallback de sessão, sem serem copiados para o snapshot.

## Verificação

Testar ida e volta JSON, leitura de snapshots antigos, fallback para foto inválida, limite combinado de imagens, restauração na tela Perfil em 320 e 390 px e falha de persistência. Executar depois a suíte Flutter, analyze e validação Web disponível; a compilação Android/Windows continua sujeita aos bloqueios nativos já registrados.

## Limitações

SharedPreferences continua local, sem criptografia, backup ou sincronização, e sujeito a cotas do navegador. A gravação pode falhar por quota; nesse caso a UI informa que a imagem ficou apenas na sessão.
