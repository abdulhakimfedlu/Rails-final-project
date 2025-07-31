class Api::CommentsController < ApplicationController
  before_action :authenticate_user, except: [:create, :index]
  
  # Create a new comment
  def create
    name = params[:name]
    phone = params[:phone]
    comment = params[:comment]
    anonymous = params[:anonymous] == true || params[:anonymous] == 'true'

    # Validation: if not anonymous, name and phone are required
    if !anonymous && (name.blank? || phone.blank?)
      render json: { 
        success: false, 
        message: 'Name and phone are required if not anonymous.' 
      }, status: :bad_request
      return
    end

    # For anonymous comments, clear name and phone
    if anonymous
      name = ''
      phone = ''
    end

    new_comment = Comment.new(
      name: name,
      phone: phone,
      comment: comment,
      anonymous: anonymous
    )

    if new_comment.save
      formatted_comment = {
        _id: new_comment.id,
        name: new_comment.name,
        phone: new_comment.phone,
        comment: new_comment.comment,
        anonymous: new_comment.anonymous,
        createdAt: new_comment.created_at,
        updatedAt: new_comment.updated_at
      }
      render json: { 
        success: true, 
        message: 'Comment submitted successfully', 
        comment: formatted_comment 
      }, status: :created
    else
      render json: { 
        success: false, 
        message: 'Failed to submit comment', 
        error: new_comment.errors.full_messages.join(', ')
      }, status: :internal_server_error
    end
  rescue => error
    render json: { 
      success: false, 
      message: 'Failed to submit comment', 
      error: error.message 
    }, status: :internal_server_error
  end

  # Get all comments
  def index
    comments = Comment.order(created_at: :desc).map do |comment|
      {
        _id: comment.id,
        name: comment.name,
        phone: comment.phone,
        comment: comment.comment,
        anonymous: comment.anonymous,
        createdAt: comment.created_at,
        updatedAt: comment.updated_at
      }
    end
    render json: { success: true, comments: comments }, status: :ok
  rescue => error
    render json: { 
      success: false, 
      message: 'Failed to fetch comments', 
      error: error.message 
    }, status: :internal_server_error
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