class Api::RatingsController < ApplicationController
  before_action :authenticate_user, except: [:create, :average]
  
  # Create a new rating
  def create
    menu = params[:menu]
    stars = params[:stars]

    if menu.blank? || stars.blank?
      render json: { message: 'Menu and stars are required.' }, status: :bad_request
      return
    end

    rating = Rating.new(
      menu_id: menu,
      stars: stars
    )

    if rating.save
      render json: rating, status: :created
    else
      render json: { errors: rating.errors }, status: :unprocessable_entity
    end
  end

  # Get all ratings for a menu item
  def by_menu
    menu_id = params[:menu_id]
    ratings = Rating.where(menu_id: menu_id).map do |rating|
      {
        _id: rating.id,
        menu_id: rating.menu_id,
        stars: rating.stars,
        created_at: rating.created_at,
        updated_at: rating.updated_at
      }
    end
    render json: ratings
  end

  # Get average rating for a menu item
  def average
    menu_id = params[:menu_id]
    
    result = Rating.where(menu_id: menu_id)
                   .group(:menu_id)
                   .average(:stars)
                   .first

    count = Rating.where(menu_id: menu_id).count

    if result.nil?
      render json: { avgRating: 0.0, count: 0 }
    else
      avg_rating = result[1].to_f # result is [menu_id, average]
      render json: { avgRating: avg_rating, count: count }
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