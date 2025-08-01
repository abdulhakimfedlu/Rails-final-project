module Authenticatable
  extend ActiveSupport::Concern

  private

  # Authentication middleware
  def authenticate_user
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token.blank?
      render json: { message: 'Access token required.' }, status: :unauthorized
      return
    end

    begin
      decoded_token = JWT.decode(token, ENV['JWT_SECRET'], true, { algorithm: 'HS256' })
      @current_user_id = decoded_token[0]['id']
    rescue JWT::DecodeError
      render json: { message: 'Invalid token.' }, status: :unauthorized
    end
  end
end