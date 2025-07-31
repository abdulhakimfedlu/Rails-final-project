module ApiHelpers
  def json_response
    JSON.parse(response.body)
  end

  def auth_headers_for(user)
    token = jwt_token_for(user)
    { 'Authorization' => "Bearer #{token}" }
  end

  def jwt_token_for(user)
    JWT.encode(
      { 
        id: user.id, 
        name: user.name, 
        phone: user.phone,
        exp: 1.day.from_now.to_i
      }, 
      ENV['JWT_SECRET'] || 'your_jwt_secret'
    )
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end