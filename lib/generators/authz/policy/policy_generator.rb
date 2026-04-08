# frozen_string_literal: true

require "rails/generators"

module Authz
  class PolicyGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)
    desc "Gera uma policy base herdando de ApplicationPolicy"

    def create_policy_file
      template "policy.rb.tt", File.join("app/policies", class_path, "#{file_name}_policy.rb")
    end
  end
end
