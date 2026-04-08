# frozen_string_literal: true

module AuthzCore
  class ActionMapper
    DEFAULT_MAPPINGS = {
      "index" => "read",
      "show" => "read",
      "new" => "create",
      "create" => "create",
      "edit" => "update",
      "update" => "update",
      "destroy" => "destroy"
    }.freeze

    def initialize(custom_mappings = {})
      @mappings = DEFAULT_MAPPINGS.merge(custom_mappings.transform_keys(&:to_s))
    end

    def permission_for(controller_name, action_name)
      module_key = normalize_controller(controller_name)
      action_key = normalize_action(action_name)

      return if module_key.empty? || action_key.empty?

      "#{module_key}.#{action_key}"
    end

    private

    def normalize_controller(controller_name)
      controller_name
        .to_s
        .underscore
        .split("/")
        .last
        .sub(/_controller\z/, "")
    end

    def normalize_action(action_name)
      @mappings.fetch(action_name.to_s, action_name.to_s)
    end
  end
end
