# authz_core

Gem Rails para padronizar autenticação, autorização e permissões dinâmicas com `Devise` + `Pundit`.

## Objetivo do MVP

- instalar a base de integração com Rails;
- sincronizar permissões a partir de controllers/actions;
- oferecer tasks para gestão inicial de roles;
- servir como ponto de partida para generators e policies.

## Estrutura inicial

- `lib/authz_core/engine.rb`
- `lib/authz_core/action_mapper.rb`
- `lib/authz_core/permission_syncer.rb`
- `lib/authz_core/role_manager.rb`
- `lib/tasks/authz_core_tasks.rake`

## Próximos passos

1. implementar migrations e models base;
2. adicionar generators `authz:install` e `authz:permissions`;
3. integrar `has_permission?` ao `User`;
4. testar em uma aplicação Rails via Docker.

## Desinstalação (Uninstall)

Para remover todos os arquivos e tabelas criados pela gem, utilize o generator de uninstall:

1. Execute o generator:
   
   ```sh
   rails generate authz:uninstall
   ```

   Isso irá remover os arquivos gerados (models, concern, initializer, policy) e criar uma migration para excluir as tabelas relacionadas à gem.

2. Rode a migration gerada:
   
   ```sh
   rails db:migrate
   ```

Pronto! Todos os artefatos da gem authz_core serão removidos do seu projeto.
