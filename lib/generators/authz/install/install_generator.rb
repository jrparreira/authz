# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module Authz
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path("templates", __dir__)
    desc "Instala a estrutura inicial do authz_core no projeto Rails"

    def create_initializer
      template "authz_core.rb.tt", "config/initializers/authz_core.rb"
    end

    def create_models
      template "permission.rb.tt", "app/models/permission.rb"
      template "role.rb.tt", "app/models/role.rb"
      template "role_permission.rb.tt", "app/models/role_permission.rb"
      template "user_permission.rb.tt", "app/models/user_permission.rb"
      template "authz_permissionable.rb.tt", "app/models/concerns/authz_permissionable.rb"
    end

    def create_policy
      return if File.exist?(File.join(destination_root, "app/policies/application_policy.rb"))

      template "application_policy.rb.tt", "app/policies/application_policy.rb"
    end

    def create_migrations
      migration_template "create_roles.rb.tt", "db/migrate/create_roles.rb"
      migration_template "create_permissions.rb.tt", "db/migrate/create_permissions.rb"
      migration_template "create_role_permissions.rb.tt", "db/migrate/create_role_permissions.rb"
      migration_template "create_user_permissions.rb.tt", "db/migrate/create_user_permissions.rb"
      migration_template "add_role_to_users.rb.tt", "db/migrate/add_role_to_users.rb"
    end

    def update_application_controller
      controller_path = File.join(destination_root, "app/controllers/application_controller.rb")
      return unless File.exist?(controller_path)
      return if File.read(controller_path).include?("include Pundit::Authorization")

      inject_into_class controller_path, "ApplicationController", "  include Pundit::Authorization\n"
    end

    def update_user_model
      user_file = File.join(destination_root, "app/models/user.rb")
      return unless File.exist?(user_file)

      inject_into_class user_file, AuthzCore.configuration.user_model_name, "  include AuthzPermissionable\n" unless File.read(user_file).include?("include AuthzPermissionable")
    end

    def show_next_steps
      say "authz_core instalado. Próximos passos sugeridos:", :green
      say "  1. revisar os models gerados"
      say "  2. rodar rails db:migrate"
      say "  3. rodar rails authz:sync_permissions"
    end

    def self.next_migration_number(path)
      ActiveRecord::Generators::Base.next_migration_number(path)
    end
  end
end
