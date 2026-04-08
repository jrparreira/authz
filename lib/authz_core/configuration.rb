# frozen_string_literal: true

module AuthzCore
  class Configuration
    attr_accessor :permission_model_name, :role_model_name, :user_model_name, :user_method_name, :controller_base_class

    def initialize
      @permission_model_name = "Permission"
      @role_model_name = "Role"
      @user_model_name = "User"
      @user_method_name = :current_user
      @controller_base_class = "::ApplicationController"
    end
  end
end
