# frozen_string_literal: true

require "active_support"
require "active_support/concern"
require "active_support/core_ext/string/inflections"
require "pundit"
require "authz_core/version"
require "authz_core/configuration"
require "authz_core/action_mapper"
require "authz_core/base_policy"
require "authz_core/user_permissionable"
require "authz_core/permission_syncer"
require "authz_core/role_manager"

module AuthzCore
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset!
      @configuration = Configuration.new
    end
  end
end

require "authz_core/engine" if defined?(Rails)
