class Api::CategoriesController < ApplicationController
  before_action :authenticate_user, except: [:index]
  
  # Create a new category
  def create
    category = Category.new(name: params[:name])
    
    if category.save
      render json: format_category(category), status: :created
    else
      render json: { errors: category.errors }, status: :unprocessable_entity
    end
  end

  # Get all categories
  def index
    categories = Category.all.map { |category| format_category(category) }
    render json: categories, status: :ok
  end

  # Update a category by ID
  def update
    category = Category.find_by(id: params[:id])
    
    if category.nil?
      render json: { message: 'Category not found' }, status: :not_found
      return
    end

    if category.update(name: params[:name])
      render json: format_category(category), status: :ok
    else
      render json: { errors: category.errors }, status: :unprocessable_entity
    end
  end

  # Delete a category by ID
  def destroy
    category = Category.find_by(id: params[:id])
    
    if category.nil?
      render json: { message: 'Category not found' }, status: :not_found
      return
    end

    # Delete all menu items under this category first
    Menu.where(category: category).destroy_all
    category.destroy
    
    render_success({}, 'Category and related menu items deleted')
  end


end