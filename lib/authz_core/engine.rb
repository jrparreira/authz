# frozen_string_literal: true

module AuthzCore
  class Engine < ::Rails::Engine
    isolate_namespace AuthzCore

    rake_tasks do
      tasks_path = root.join("lib/tasks/authz_core_tasks.rake")
      load tasks_path if tasks_path.exist?
    end
  end
end
