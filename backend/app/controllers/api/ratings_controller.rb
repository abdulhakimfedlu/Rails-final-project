class Api::RatingsController < ApplicationController
  before_action :authenticate_user, except: [:create, :average]
  
  # Create a new rating
  def create
    validate_required_params({ menu: params[:menu], stars: params[:stars] })
    return if performed?

    rating = Rating.new(
      menu_id: params[:menu],
      stars: params[:stars]
    )

    if rating.save
      render json: format_rating(rating), status: :created
    else
      render json: { errors: rating.errors }, status: :unprocessable_entity
    end
  end

  # Get all ratings for a menu item
  def by_menu
    menu_id = params[:menu_id]
    ratings = Rating.where(menu_id: menu_id).map { |rating| format_rating(rating) }
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


end