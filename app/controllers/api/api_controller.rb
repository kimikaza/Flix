class Api::ApiController < ApplicationController
  protect_from_forgery with: :null_session

  RESPONSE_STATUSES = {
    bad_request: {
      code: 400,
      text: "Bad Request"
    },
    not_found: {
      code: 404,
      text: "Not Found"
    },
    internal_server_error: {
      code: 500,
      text: "Internal Server Error"
    },
    not_implemented: {
      code: 501,
      text: "Not Implemented / Not Available"
    },
    unauthorized: {
      code: 401,
      text: "Unauthorized"
    },
    expired_token: {
      code: 1000,
      text: "Expired Token"
    }
  }

  protected

  def respond_with_error(status, message)
    @status = RESPONSE_STATUSES[status]
    @message = message

    
    render "api/v1/shared/error", status: status, layout: false
    
  rescue ActionController::UnknownFormat
    render status: @status[:code], text: message
  end
  
end
