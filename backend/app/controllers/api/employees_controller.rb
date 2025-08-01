class Api::EmployeesController < ApplicationController
  before_action :authenticate_user
  
  # Create a new employee
  def create
    image_url = params[:image]
    
    # Handle file upload with Cloudinary
    if params[:image].present? && params[:image].respond_to?(:tempfile)
      uploaded_url = ImageUploadService.upload(params[:image])
      image_url = uploaded_url if uploaded_url
    end

    employee_params = {
      name: params[:name],
      phone: params[:phone],
      image: image_url,
      position: params[:position],
      salary: params[:salary],
      date_hired: params[:dateHired] || params[:date_hired] || Time.current,
      description: params[:description],
      working_hour: params[:workingHour] || params[:working_hour],
      status: params[:status] || 'active',
      reason_for_leaving: params[:reasonForLeaving] || params[:reason_for_leaving] || ''
    }

    # Ensure tableAssigned is only set if position is waiter
    if params[:position] == 'waiter'
      employee_params[:table_assigned] = params[:tableAssigned] || params[:table_assigned]
    end

    employee = Employee.new(employee_params)

    if employee.save
      render json: format_employee(employee), status: :created
    else
      render json: { errors: employee.errors }, status: :unprocessable_entity
    end
  end

  # Get all employees
  def index
    employees = Employee.all.map { |employee| format_employee(employee) }
    render json: employees
  end

  # Get a single employee by ID
  def show
    employee = Employee.find(params[:id])
    render json: format_employee(employee)
  end

  # Update an employee
  def update
    employee = Employee.find(params[:id])

    image_url = params[:image]
    
    # Handle file upload with Cloudinary
    if params[:image].present? && params[:image].respond_to?(:tempfile)
      uploaded_url = ImageUploadService.upload(params[:image])
      image_url = uploaded_url if uploaded_url
    end

    update_params = {
      name: params[:name],
      phone: params[:phone],
      image: image_url,
      position: params[:position],
      salary: params[:salary],
      description: params[:description],
      working_hour: params[:workingHour] || params[:working_hour],
      status: params[:status],
      reason_for_leaving: params[:reasonForLeaving] || params[:reason_for_leaving]
    }

    # Handle table assignment based on position
    if params[:position]
      if params[:position] == 'waiter'
        update_params[:table_assigned] = params[:tableAssigned] || params[:table_assigned]
      else
        # If changing to non-waiter position, clear table assignment
        update_params[:table_assigned] = nil
      end
    end

    if employee.update(update_params.reject { |k, v| v.nil? && k != :table_assigned })
      render json: format_employee(employee)
    else
      render json: { errors: employee.errors }, status: :unprocessable_entity
    end
  end

  # Delete an employee
  def destroy
    employee = Employee.find(params[:id])
    employee.destroy
    render_success({}, 'Employee deleted')
  end


end