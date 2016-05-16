class Api::V1::UsersController < Api::ApiController

def authenticate
    user = User.find_by(email: params.require(:email))
    if user
      if user.valid_password?(params.require(:password))
        if user.save
          @token = user.authentication_token
          @success = true
        else
          respond_with_error(:unauthorized, "Error while accessing user's token")
        end
      else
        respond_with_error(:unauthorized, "The email/password combination provided is invalid.")
      end
    else
      respond_with_error(:unauthorized, "The email/password combination provided is invalid.")
    end
  end

end
