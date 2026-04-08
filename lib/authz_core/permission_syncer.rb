# frozen_string_literal: true

require "logger"

module AuthzCore
  class PermissionSyncer
    def initialize(action_mapper: ActionMapper.new, permission_model: nil, logger: nil)
      @action_mapper = action_mapper
      @permission_model = permission_model || resolve_permission_model
      @logger = logger || default_logger
    end

    def discovered_permissions
      return [] unless defined?(ApplicationController)

      Rails.application.eager_load! if defined?(Rails) && Rails.application

      controller_classes
        .flat_map { |controller_class| permissions_for_controller(controller_class) }
        .uniq
        .sort
    end

    def sync!
      raise Error, "Permission model not found" unless @permission_model

      discovered_permissions.filter_map do |permission_key|
        permission = @permission_model.find_or_initialize_by(key: permission_key)
        next unless permission.new_record?

        permission.name = permission_key.tr(".", " ").humanize
        permission.module_name = permission_key.split(".").first if permission.respond_to?(:module_name=)
        permission.save!
        @logger.info("[authz_core] created permission #{permission_key}")
        permission
      end
    end

    private

    def controller_classes
      ApplicationController.descendants.reject(&:anonymous?)
    end

    def permissions_for_controller(controller_class)
      controller_class.action_methods.map do |action_name|
        @action_mapper.permission_for(controller_class.name, action_name)
      end.compact
    end

    def resolve_permission_model
      AuthzCore.configuration.permission_model_name.safe_constantize
    end

    def default_logger
      return Rails.logger if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger

      Logger.new($stdout)
    end
  end
end
