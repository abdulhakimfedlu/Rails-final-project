class Api::UsersController < ApplicationController
  before_action :authenticate_user, only: [:current_user, :change_password, :update_phone_number]

  # Register a new user
  def register
    validate_required_params({ name: params[:name], phone: params[:phone], password: params[:password] })
    return if performed?

    # Check if phone number already exists
    if User.exists?(phone: params[:phone])
      return render_error('User already exists.')
    end

    # Hash password
    hashed_password = BCrypt::Password.create(params[:password])

    user = User.new(
      name: params[:name],
      phone: params[:phone],
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
    validate_required_params({ phone: params[:phone], password: params[:password] })
    return if performed?

    user = User.find_by(phone: params[:phone])
    if user.nil? || BCrypt::Password.new(user.password) != params[:password]
      return render_error('Invalid phone or password.', :unauthorized)
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
    user = User.find(@current_user_id)
    render json: { user: user }
  end

  # Change password
  def change_password
    validate_required_params({ oldPassword: params[:oldPassword], newPassword: params[:newPassword] })
    return if performed?

    user = User.find(@current_user_id)

    unless BCrypt::Password.new(user.password) == params[:oldPassword]
      return render_error('Old password is incorrect.', :unauthorized)
    end

    user.password = BCrypt::Password.create(params[:newPassword])

    if user.save
      render_success({}, 'Password changed successfully.')
    else
      render json: { errors: user.errors }, status: :unprocessable_entity
    end
  end

  # Update phone number
  def update_phone_number
    validate_required_params({ newPhone: params[:newPhone], password: params[:password] })
    return if performed?

    # Check if new phone is already in use
    existing_user = User.find_by(phone: params[:newPhone])
    if existing_user && existing_user.id != @current_user_id
      return render_error('Phone number already in use.')
    end

    user = User.find(@current_user_id)

    unless BCrypt::Password.new(user.password) == params[:password]
      return render_error('Password is incorrect.', :unauthorized)
    end

    user.phone = params[:newPhone]

    if user.save
      # Exclude password from response
      user_obj = user.as_json(except: [:password])
      render_success({ user: user_obj }, 'Phone number updated successfully.')
    else
      render json: { errors: user.errors }, status: :unprocessable_entity
    end
  end


end