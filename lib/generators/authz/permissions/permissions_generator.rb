# frozen_string_literal: true

module Authz
  class PermissionsGenerator < Rails::Generators::Base
    argument :controller_name, type: :string

    desc "Mostra as permissões sugeridas para um controller específico"

    def preview_permissions
      mapper = AuthzCore::ActionMapper.new
      suggestions = actions_for(controller_name).map do |action_name|
        mapper.permission_for(controller_name, action_name)
      end.uniq.compact

      say "Permissões sugeridas para #{controller_name}:", :green
      suggestions.each { |permission| say "  - #{permission}" }
    end

    private

    def actions_for(name)
      controller_class = name.to_s.safe_constantize
      return controller_class.action_methods.to_a.sort if controller_class&.respond_to?(:action_methods)

      %w[index show new create edit update destroy]
    end
  end
end
