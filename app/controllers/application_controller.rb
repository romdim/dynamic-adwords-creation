require 'adwords_api'

class ApplicationController < ActionController::Base

  before_action :authenticate
  protect_from_forgery

  private

  # Returns the API version in use.
  def get_api_version()
    return :v201702
  end

  # Returns currently selected account.
  def selected_account()
    @selected_account ||= session[:selected_account]
    return @selected_account
  end

  # Sets current account to the specified one.
  def selected_account=(new_selected_account)
    @selected_account = new_selected_account
    session[:selected_account] = @selected_account
  end

  # Checks if we have a valid credentials.
  def authenticate()
    token = session[:token]
    redirect_to login_prompt_path if token.nil?
    return !token.nil?
  end

  # Returns an API object.
  def get_adwords_api()
    @api ||= create_adwords_api()
    return @api
  end

  # Creates an instance of AdWords API class. Uses a configuration file and
  # Rails config directory.
  def create_adwords_api()
    @api = AdwordsApi::Api.new({
      authentication: {
        method: 'OAuth2',
        oauth2_client_id: ENV['OAUTH2_CLIENT_ID'],
        oauth2_client_secret: ENV['OAUTH2_CLIENT_SECRET'],
        developer_token: ENV['DEVELOPER_TOKEN'],
        user_agent: 'dac'
      },
      service: {
        environment: 'PRODUCTION'
      },
      connection: {
        enable_gzip: true
      },
      library: {
        log_level: 'INFO'
      }
    })
    token = session[:token]
    # If we have an OAuth2 token in session we use the credentials from it.
    if token
      credentials = @api.credential_handler()
      credentials.set_credential(:oauth2_token, token)
      credentials.set_credential(:client_customer_id, selected_account)
    end
    return @api
  end
end
