# Manual de Uso da authz_core

Guia pratico para instalar e usar a gem `authz_core` com `Devise` e `Pundit`.

## 1) Dependencias necessarias

Antes de usar a `authz_core`, o projeto precisa ter:

- Ruby on Rails funcionando
- `devise` instalado e configurado
- um model autenticavel criado pelo Devise (`User`, `Admin`, `Member`, etc.)
- `pundit` instalado

Observacao importante:

- a `authz_core` funciona com **um unico model autenticavel principal por vez**
- uso com multiplos scopes simultaneos do Devise nao e o fluxo recomendado atual

---

## 2) Passo a passo de instalacao

### Passo 1: instalar e configurar Devise

Exemplo com `User`:

```bash
rails generate devise:install
rails generate devise User
rails db:migrate
```

Se seu model autenticavel for outro, troque no generate:

```bash
rails generate devise Admin
```

### Passo 2: instalar Pundit

```bash
bundle add pundit
```

### Passo 3: adicionar a authz_core no Gemfile

```ruby
gem 'authz_core'
```

Depois:

```bash
bundle install
```

### Passo 4: rodar o install da authz_core

```bash
rails generate authz:install
```

Esse comando gera:

- `config/initializers/authz_core.rb`
- models de autorizacao (`Role`, `Permission`, `RolePermission`, `UserPermission`)
- `app/policies/application_policy.rb`
- migrations da estrutura de permissao
- `include Pundit::Authorization` no `ApplicationController`

### Passo 5: ajustar o initializer se nao usar User

Arquivo:

`config/initializers/authz_core.rb`

Exemplo com `Admin`:

```ruby
AuthzCore.configure do |config|
  config.permission_model_name = "Permission"
  config.role_model_name = "Role"
  config.user_model_name = "Admin"
  config.user_method_name = :current_admin
end
```

Exemplo com `Member`:

```ruby
AuthzCore.configure do |config|
  config.permission_model_name = "Permission"
  config.role_model_name = "Role"
  config.user_model_name = "Member"
  config.user_method_name = :current_member
end
```

### Passo 6: rodar migrations

```bash
rails db:migrate
```

### Passo 7: sincronizar permissoes iniciais

```bash
rails authz:sync_permissions
```

---

## 3) Como a sync de permissoes funciona

O comando `rails authz:sync_permissions` le os controllers e cria permissao ausente na tabela `permissions`.

Mapeamento padrao de actions:

- `index`, `show` -> `.read`
- `new`, `create` -> `.create`
- `edit`, `update` -> `.update`
- `destroy` -> `.destroy`

Exemplo para `ContractsController`:

- `contracts.read`
- `contracts.create`
- `contracts.update`
- `contracts.destroy`

Observacao:

- o namespace do controller nao e usado na chave final
- `Admin::ContractsController` e `ContractsController` geram `contracts.*`

---

## 4) Comandos disponiveis e o que cada um faz

### `rails generate authz:install`

Instala a estrutura da gem no projeto (initializer, models, policy base e migrations).

### `rails authz:sync_permissions`

Sincroniza as permissoes no banco com base nas actions dos controllers.

### `bundle exec rake "authz:role:create[key,name]"`

Cria uma role.

Exemplo:

```bash
bundle exec rake "authz:role:create[manager,Manager]"
```

### `bundle exec rake "authz:role:update[role_key,permission_keys]"`

Substitui o conjunto de permissoes de uma role.

Exemplo:

```bash
bundle exec rake "authz:role:update[manager,users.read users.update finance.read]"
```

### `bundle exec rake "authz:role:grant[role_key,permission_key]"`

Concede uma permissao para a role.

Exemplo:

```bash
bundle exec rake "authz:role:grant[manager,contracts.read]"
```

### `bundle exec rake "authz:role:revoke[role_key,permission_key]"`

Revoga uma permissao da role.

Exemplo:

```bash
bundle exec rake "authz:role:revoke[manager,contracts.read]"
```

---

## 5) Modelo de permissao

A authz_core suporta dois niveis:

- permissoes por role (`role_permissions`)
- excecoes por usuario (`user_permissions`)

Regra recomendada:

1. admin tem acesso total
2. se houver regra individual do usuario, ela prevalece
3. sem regra individual, vale a permissao herdada da role

---

## 6) Fluxo recomendado no dia a dia

1. criar/alterar controllers
2. rodar `rails authz:sync_permissions`
3. criar/ajustar roles com tarefas `authz:role:*`
4. configurar excecoes por usuario quando necessario

---

## 7) Dicas rapidas

- use `bundle exec rake -T authz` para listar tasks disponiveis
- dados criados por tasks vao para o banco atual; se quiser em todos ambientes, use seed/bootstrap
- se `bundle add pundit` falhar por duplicidade, verifique se `pundit` ja esta no Gemfile

---

## 8) Desinstalação (Uninstall)

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
