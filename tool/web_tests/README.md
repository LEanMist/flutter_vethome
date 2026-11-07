# Verificação de Web Locks no navegador

Execute o teste no Chrome real com:

```powershell
dart test -p chrome tool/web_tests/local_storage_web_lock_cross_context_test.dart
```

O documento principal usa o helper de lock de produção. Um `iframe` same-origin
faz uma segunda solicitação independente do mesmo recurso. O teste consulta a
fila do navegador, confirma clientes distintos, verifica que a segunda
solicitação aguarda e só entra depois da liberação.

Isso valida exclusão mútua do Web Locks entre documentos do navegador. Não
inicializa duas aplicações Flutter completas nem valida a mesclagem de dados
persistidos por duas instâncias de `LocalStorage`.
