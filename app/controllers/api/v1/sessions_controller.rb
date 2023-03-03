# frozen_string_literal: true

module Api
  module V1
    class SessionsController < DeviseTokenAuth::SessionsController
      protect_from_forgery with: :null_session
      include Api::Concerns::ActAsApiRequest

      def_param_group(:user) do
        property :id, Integer
        property :active?, [true, false]
        property :uid, String
        param :username, String, required: true
        param :email, String, required: true
        param :device_token, String
        param :app_platform, String, desc: "Possible values: #{User.app_platforms.keys}", required: true
        param :app_version, String, required: true
      end

      api :POST, "users/sign_in.json", "User login"
      example <<~EOS
        HEADERS: {
          "Content-Type": "application/json",
          "App-Platform": "Possible values: #{User.app_platforms.keys}",
          "App-Version": "1"
        }
      EOS
      error 422, "Unprocessable Entity"
      description "Authorization not required, It will return access-token, client, uid in header, which required for authorization"
      param :email, String, required: true
      param :password, String, required: true
      param :device_token, String, required: true
      returns :user, code: 201, desc: "a successful response"

      def create
        client = OAuth2::Client.new(client_id, client_secret, site: 'https://oauth.provider.com')
        token = client.password.get_token(params[:email], params[:password])
      end

      api :Delete, "users/sign_out.json", "User logout"

      def destroy
        # remove auth instance variables so that after_action does not run
        user = @resource ? remove_instance_variable(:@resource) : nil
        client = @token.client
        @token.clear!

        if user
          if client && user.tokens[client]
            user.tokens.delete(client)
          end

          user.update(device_token: "")
          render_destroy_success
        else
          render_destroy_error
        end
      end

      protected

      def render_create_success
        render_resource(@resource)
      end

      def render_create_error_bad_credentials
        render_error(422, I18n.t("devise_token_auth.sessions.bad_credentials"))
      end

      def render_create_error_account_locked
        if @resource.active_for_authentication?
          render_error(401, I18n.t("devise.mailer.unlock_instructions.account_lock_msg"))
        else
          render_create_error_not_confirmed
        end
      end

      def render_create_error_not_confirmed
        render_error(401, I18n.t("devise.failure.#{@resource.inactive_message}"))
      end

      def render_destroy_error
        render_error(422, I18n.t("devise_token_auth.sessions.user_not_found"))
      end

      private

      def resource_params
        params.permit(:email, :password)
      end

      def resource_update_params
        params.permit(:device_token).merge(app_platform: request.headers["app-platform"], app_version: request.headers["app-version"])
      end
    end
  end
end
