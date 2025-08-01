class Api::MenusController < ApplicationController
  before_action :authenticate_user, except: [:by_category]
  
  # Update a menu item
  def update
    menu = Menu.find(params[:id])

    image_url = params[:image]
    
    # Handle file upload with Cloudinary
    if params[:image].present? && params[:image].respond_to?(:tempfile)
      uploaded_url = ImageUploadService.upload(params[:image])
      image_url = uploaded_url if uploaded_url
    end

    update_data = {
      name: params[:name],
      ingredients: params[:ingredients],
      price: params[:price],
      badge: params[:badge],
      category_id: params[:category_id] || params[:category]
    }

    # Handle boolean parameters explicitly
    if params.has_key?(:available)
      update_data[:available] = params[:available] == true || params[:available] == 'true'
    end

    if params.has_key?(:outOfStock)
      update_data[:out_of_stock] = params[:outOfStock] == true || params[:outOfStock] == 'true'
    elsif params.has_key?(:out_of_stock)
      update_data[:out_of_stock] = params[:out_of_stock] == true || params[:out_of_stock] == 'true'
    end

    # If image is explicitly set to empty string, remove image
    if params[:image] == ''
      update_data[:image] = ''
    elsif image_url
      update_data[:image] = image_url
    end

    if menu.update(update_data.compact)
      render json: format_menu(menu)
    else
      render json: { errors: menu.errors }, status: :unprocessable_entity
    end
  end

  # Delete a menu item
  def destroy
    menu = Menu.find(params[:id])
    menu.destroy
    render_success({}, 'Menu item deleted')
  end

  # Get all menu items by category
  def by_category
    menus = Menu.where(category_id: params[:category_id])
    formatted_menus = menus.map { |menu| format_menu(menu) }
    render json: formatted_menus
  end

  # Create a new menu item under a category
  def create_under_category
    image_url = params[:image]
    
    # Handle file upload with Cloudinary
    if params[:image].present? && params[:image].respond_to?(:tempfile)
      uploaded_url = ImageUploadService.upload(params[:image])
      image_url = uploaded_url if uploaded_url
    end

    # Ensure category is set from params
    menu = Menu.new(
      name: params[:name],
      ingredients: params[:ingredients],
      price: params[:price],
      image: image_url,
      available: params[:available] != false,
      out_of_stock: params[:outOfStock] == true || params[:out_of_stock] == true,
      badge: params[:badge],
      category_id: params[:category_id] || params[:category]
    )

    if menu.save
      render json: format_menu(menu), status: :created
    else
      render json: { errors: menu.errors }, status: :unprocessable_entity
    end
  end


end