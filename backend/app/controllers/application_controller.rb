class ApplicationController < ActionController::API
  include Authenticatable
  include ErrorHandler
  include ResponseFormatter
end
