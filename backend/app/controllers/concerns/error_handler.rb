module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  end

  private

  def handle_standard_error(exception)
    render json: { 
      success: false, 
      message: 'An error occurred', 
      error: exception.message 
    }, status: :internal_server_error
  end

  def record_not_found(exception)
    render json: { 
      success: false, 
      message: 'Record not found' 
    }, status: :not_found
  end
  
  def record_invalid(exception)
    render json: { 
      success: false, 
      errors: exception.record.errors.full_messages 
    }, status: :unprocessable_entity
  end

  # Helper method for consistent success responses
  def render_success(data = {}, message = nil, status = :ok)
    response = { success: true }
    response[:message] = message if message
    response.merge!(data)
    render json: response, status: status
  end

  # Helper method for consistent error responses
  def render_error(message, status = :bad_request, errors = nil)
    response = { success: false, message: message }
    response[:errors] = errors if errors
    render json: response, status: status
  end
end