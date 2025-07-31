class Api::UsersController < ApplicationController
  before_action :authenticate_user, only: [:current_user, :change_password, :update_phone_number]

  # Register a new user
  def register
    name = params[:name]
    phone = params[:phone]
    password = params[:password]

    if name.blank? || phone.blank? || password.blank?
      render json: { message: 'Name, phone, and password are required.' }, status: :bad_request
      return
    end

    # Check if phone number already exists
    user_available = User.find_by(phone: phone)
    if user_available
      render json: { message: 'User already exists.' }, status: :bad_request
      return
    end

    # Hash password
    hashed_password = BCrypt::Password.create(password)

    user = User.new(
      name: name,
      phone: phone,
      password: hashed_password
    )

    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors }, status: :unprocessable_entity
    end
  end

  # Login user
  def login
    phone = params[:phone]
    password = params[:password]

    if phone.blank? || password.blank?
      render json: { message: 'Phone and password are required.' }, status: :bad_request
      return
    end

    user = User.find_by(phone: phone)
    if user.nil?
      render json: { message: 'Invalid phone or password.' }, status: :unauthorized
      return
    end

    is_match = BCrypt::Password.new(user.password) == password

    unless is_match
      render json: { message: 'Invalid phone or password.' }, status: :unauthorized
      return
    end

    token = JWT.encode(
      { 
        id: user.id, 
        name: user.name, 
        phone: user.phone,
        exp: 1.day.from_now.to_i
      }, 
      ENV['JWT_SECRET'] || 'your_jwt_secret'
    )

    render json: { token: token, user: user }
  end

  # Get current user
  def current_user
    user = User.find_by(id: @current_user_id)
    
    if user.nil?
      render json: { message: 'User not found.' }, status: :unauthorized
      return
    end

    render json: { user: user }
  end

  # Change password
  def change_password
    user_id = @current_user_id
    old_password = params[:oldPassword]
    new_password = params[:newPassword]

    if old_password.blank? || new_password.blank?
      render json: { message: 'Old and new password are required.' }, status: :bad_request
      return
    end

    user = User.find_by(id: user_id)
    if user.nil?
      render json: { message: 'User not found.' }, status: :not_found
      return
    end

    is_match = BCrypt::Password.new(user.password) == old_password
    unless is_match
      render json: { message: 'Old password is incorrect.' }, status: :unauthorized
      return
    end

    hashed_password = BCrypt::Password.create(new_password)
    user.password = hashed_password

    if user.save
      render json: { message: 'Password changed successfully.' }
    else
      render json: { errors: user.errors }, status: :unprocessable_entity
    end
  end

  # Update phone number
  def update_phone_number
    user_id = @current_user_id
    new_phone = params[:newPhone]
    password = params[:password]

    if new_phone.blank? || password.blank?
      render json: { message: 'New phone and password are required.' }, status: :bad_request
      return
    end

    # Check if new phone is already in use
    existing_user = User.find_by(phone: new_phone)
    if existing_user && existing_user.id != user_id
      render json: { message: 'Phone number already in use.' }, status: :bad_request
      return
    end

    user = User.find_by(id: user_id)
    if user.nil?
      render json: { message: 'User not found.' }, status: :not_found
      return
    end

    is_match = BCrypt::Password.new(user.password) == password
    unless is_match
      render json: { message: 'Password is incorrect.' }, status: :unauthorized
      return
    end

    user.phone = new_phone

    if user.save
      # Exclude password from response
      user_obj = user.as_json(except: [:password])
      render json: { message: 'Phone number updated successfully.', user: user_obj }
    else
      render json: { errors: user.errors }, status: :unprocessable_entity
    end
  end

  private

  # Authentication middleware
  def authenticate_user
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token.blank?
      render json: { message: 'Access token required.' }, status: :unauthorized
      return
    end

    begin
      decoded_token = JWT.decode(token, ENV['JWT_SECRET'] || 'your_jwt_secret', true, { algorithm: 'HS256' })
      @current_user_id = decoded_token[0]['id']
    rescue JWT::DecodeError
      render json: { message: 'Invalid token.' }, status: :unauthorized
    end
  end
end