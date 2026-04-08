# frozen_string_literal: true

module AuthzCore
  module UserPermissionable
    extend ActiveSupport::Concern

    def has_permission?(permission_key)
      key = permission_key.to_s
      return false if key.empty?
      return true if authz_admin?

      override = authz_permission_override_for(key)
      return override.allowed if override

      authz_role_permissions.include?(key)
    end

    def authz_permission_keys
      (authz_role_permissions + authz_allowed_user_permissions).uniq
    end

    private

    def authz_admin?
      respond_to?(:role) && role&.respond_to?(:key) && role.key.to_s == "admin"
    end

    def authz_permission_override_for(permission_key)
      return unless respond_to?(:user_permissions)

      user_permissions.joins(:permission).find_by(permissions: { key: permission_key })
    end

    def authz_allowed_user_permissions
      return [] unless respond_to?(:user_permissions)

      user_permissions
        .includes(:permission)
        .select(&:allowed?)
        .map { |entry| entry.permission&.key }
        .compact
    end

    def authz_role_permissions
      return [] unless respond_to?(:role) && role&.respond_to?(:permissions)

      role.permissions.pluck(:key)
    end
  end
end
