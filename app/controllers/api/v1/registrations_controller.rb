# frozen_string_literal: true

module Api
  module V1
    class RegistrationsController < DeviseTokenAuth::RegistrationsController
      protect_from_forgery with: :null_session
      include Api::Concerns::ActAsApiRequest
      before_action :authenticate_user!, only: :update

      def_param_group(:user) do
        property :id, Integer
        property :active?, [true, false]
        param :username, String, required: true
        param :app_platform, String, desc: "Possible values: #{User.app_platforms.keys}", required: true
        param :app_version, String, required: true
        param :device_token, String
      end

      api :POST, "users.json", "User Signup"
      error 422, "Unprocessable Entity"
      param_group :user
      returns :user, code: 201

      def create
        super
      end
      #TODO: This is commented for now will use it when needed
      # api :PUT, "users.json", "Reader Update"
      # error 422, "Unprocessable Entity"
      # param_group :user
      # returns :user, code: 201

      def update
        super
      rescue ArgumentError => e
        render_error(433, e.message)
      end

      private

      def sign_up_params
        params.permit(:email, :password, :username, :device_token, :app_platform, :app_version)
      end

      def account_update_params
        params.permit( :email, :username, :phone_number, :device_token, :app_platform, :app_version)
      end

      def render_create_success
        render_resource(@resource, 201)
      end

      def render_update_success
        render_resource(@resource)
      end

      def render_create_error
        render_resource_error(@resource)
      end

      def render_update_error
        render_resource_error(@resource)
      end
    end
  end
end
