class ApplicationController < ActionController::API
  # Global error handling
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  
  private
  
  def record_not_found(exception)
    render json: { message: 'Record not found' }, status: :not_found
  end
  
  def record_invalid(exception)
    render json: { errors: exception.record.errors }, status: :unprocessable_entity
  end
end
