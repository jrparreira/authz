# frozen_string_literal: true

require_relative "lib/authz_core/version"

Gem::Specification.new do |spec|
  spec.name = "authz_core"
  spec.version = AuthzCore::VERSION
  spec.authors = ["JR Parreira"]
  spec.email = ["dev@example.com"]

  spec.summary = "Dynamic authentication and authorization helpers for Rails apps"
  spec.description = "Rails engine that integrates Devise, Pundit, and dynamic roles and permissions with sync tasks."
  spec.homepage = "https://example.com/authz_core"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir[
    "lib/**/*",
    "README.md",
    "Rakefile"
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency "devise", ">= 4.9"
  spec.add_dependency "pundit", ">= 2.3"
  spec.add_dependency "rails", ">= 7.0"
end
