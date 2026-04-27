require 'rails/generators'

module Authz
  module Generators
    class UninstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Remove arquivos e gera migration para excluir tabelas da AuthzCore.'

      def remove_initializer
        initializer = 'config/initializers/authz_core.rb'
        if File.exist?(initializer)
          remove_file initializer
        end
      end

      def remove_models
        %w[role.rb permission.rb user_permission.rb role_permission.rb].each do |model|
          path = File.join('app/models', model)
          remove_file path if File.exist?(path)
        end
      end

      def remove_concerns
        concern = 'app/models/concerns/authz_permissionable.rb'
        remove_file concern if File.exist?(concern)
      end

      def remove_policy
        policy = 'app/policies/application_policy.rb'
        remove_file policy if File.exist?(policy)
      end

      def create_drop_tables_migration
        migration_template 'drop_authz_tables.rb.tt', "db/migrate/drop_authz_tables.rb"
      end
    end
  end
end
