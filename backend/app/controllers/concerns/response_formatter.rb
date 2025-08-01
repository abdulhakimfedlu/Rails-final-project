module ResponseFormatter
  extend ActiveSupport::Concern

  private

  # Format comment for API response
  def format_comment(comment)
    {
      _id: comment.id,
      name: comment.name,
      phone: comment.phone,
      comment: comment.comment,
      anonymous: comment.anonymous
    }
  end

  # Format category for API response
  def format_category(category)
    {
      _id: category.id,
      name: category.name
    }
  end

  # Format employee for API response
  def format_employee(employee)
    {
      _id: employee.id,
      name: employee.name,
      phone: employee.phone,
      image: employee.image,
      position: employee.position,
      salary: employee.salary,
      dateHired: employee.date_hired,
      description: employee.description,
      workingHour: employee.working_hour,
      tableAssigned: employee.table_assigned,
      status: employee.status,
      reasonForLeaving: employee.reason_for_leaving
    }
  end

  # Format menu for API response
  def format_menu(menu)
    {
      _id: menu.id,
      name: menu.name,
      ingredients: menu.ingredients,
      price: menu.price.to_f,
      image: menu.image,
      available: menu.available,
      outOfStock: menu.out_of_stock,
      badge: menu.badge,
      category_id: menu.category_id
    }
  end

  # Format rating for API response
  def format_rating(rating)
    {
      _id: rating.id,
      menu_id: rating.menu_id,
      stars: rating.stars
    }
  end

  # Validate required parameters
  def validate_required_params(params_hash)
    missing_params = params_hash.select { |key, value| value.blank? }.keys
    return if missing_params.empty?
    
    render_error("#{missing_params.join(', ')} #{missing_params.size > 1 ? 'are' : 'is'} required.")
  end
end