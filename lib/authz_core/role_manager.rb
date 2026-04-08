# frozen_string_literal: true

module AuthzCore
  class RoleManager
    def initialize(role_model: nil, permission_model: nil)
      @role_model = role_model || AuthzCore.configuration.role_model_name.safe_constantize
      @permission_model = permission_model || AuthzCore.configuration.permission_model_name.safe_constantize
    end

    def create_role!(key:, name: nil, description: nil)
      raise Error, "Role model not found" unless @role_model

      @role_model.find_or_create_by!(key: key) do |role|
        role.name = name || key.to_s.humanize if role.respond_to?(:name=)
        role.description = description if role.respond_to?(:description=)
      end
    end

    def update_permissions!(role_key, permission_keys)
      role = find_role!(role_key)
      keys = Array(permission_keys).map(&:to_s).map(&:strip).reject(&:empty?).uniq
      permissions = @permission_model.where(key: keys)
      missing_keys = keys - permissions.pluck(:key)

      raise Error, "Permissions not found: #{missing_keys.join(', ')}" if missing_keys.any?

      role.permissions = permissions
      role
    end

    def grant!(role_key, permission_key)
      role = find_role!(role_key)
      permission = find_permission!(permission_key)

      role.permissions << permission unless role.permissions.exists?(permission.id)
      permission
    end

    def revoke!(role_key, permission_key)
      role = find_role!(role_key)
      permission = find_permission!(permission_key)

      role.permissions.destroy(permission)
    end

    private

    def find_role!(role_key)
      raise Error, "Role model not found" unless @role_model

      @role_model.find_by!(key: role_key)
    end

    def find_permission!(permission_key)
      raise Error, "Permission model not found" unless @permission_model

      @permission_model.find_by!(key: permission_key)
    end
  end
end
