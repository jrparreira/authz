# frozen_string_literal: true

require "rake"
extend Rake::DSL

namespace :authz do
  desc "Sync permissions from controllers and actions"
  task sync_permissions: :environment do
    created_permissions = AuthzCore::PermissionSyncer.new.sync!
    puts "[authz_core] synced #{created_permissions.count} new permission(s)"
  end

  namespace :role do
    desc "Create a role: rake authz:role:create[manager,Manager]"
    task :create, %i[key name] => :environment do |_task, args|
      key = args[:key].to_s.strip
      abort("Usage: rake authz:role:create[key,name]") if key.empty?

      role = AuthzCore::RoleManager.new.create_role!(key: key, name: args[:name])
      puts "[authz_core] role ready: #{role.respond_to?(:key) ? role.key : key}"
    end

    desc "Replace a role permission set: rake authz:role:update[manager,contracts.read users.read]"
    task :update, %i[role_key permission_keys] => :environment do |_task, args|
      abort("Usage: rake authz:role:update[role_key,permission_keys]") if args[:role_key].to_s.empty? || args[:permission_keys].to_s.empty?

      keys = args[:permission_keys].to_s.split(/[\s,]+/)
      role = AuthzCore::RoleManager.new.update_permissions!(args[:role_key], keys)
      puts "[authz_core] updated #{role.respond_to?(:key) ? role.key : args[:role_key]} with #{keys.size} permission(s)"
    end

    desc "Grant a permission to a role: rake authz:role:grant[manager,contracts.read]"
    task :grant, %i[role_key permission_key] => :environment do |_task, args|
      abort("Usage: rake authz:role:grant[role_key,permission_key]") if args[:role_key].to_s.empty? || args[:permission_key].to_s.empty?

      AuthzCore::RoleManager.new.grant!(args[:role_key], args[:permission_key])
      puts "[authz_core] granted #{args[:permission_key]} to #{args[:role_key]}"
    end

    desc "Revoke a permission from a role: rake authz:role:revoke[manager,contracts.read]"
    task :revoke, %i[role_key permission_key] => :environment do |_task, args|
      abort("Usage: rake authz:role:revoke[role_key,permission_key]") if args[:role_key].to_s.empty? || args[:permission_key].to_s.empty?

      AuthzCore::RoleManager.new.revoke!(args[:role_key], args[:permission_key])
      puts "[authz_core] revoked #{args[:permission_key]} from #{args[:role_key]}"
    end
  end
end
