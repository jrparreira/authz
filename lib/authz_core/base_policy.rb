# frozen_string_literal: true

module AuthzCore
  class BasePolicy
    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
    end

    def index?
      allowed_for?(:read)
    end

    def show?
      allowed_for?(:read)
    end

    def new?
      create?
    end

    def create?
      allowed_for?(:create)
    end

    def edit?
      update?
    end

    def update?
      allowed_for?(:update)
    end

    def destroy?
      allowed_for?(:destroy)
    end

    def allowed_for?(action)
      return false unless user&.respond_to?(:has_permission?)

      user.has_permission?("#{permission_prefix}.#{action}")
    end

    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        scope.all
      end
    end

    private

    def permission_prefix
      target = record.is_a?(Class) ? record : record.class

      if target.respond_to?(:model_name)
        target.model_name.route_key
      else
        target.name.to_s.underscore.pluralize
      end
    end
  end
end
