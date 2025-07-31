require 'rails_helper'

RSpec.describe 'Api::Users', type: :request do
  let(:valid_user_params) do
    {
      name: 'John Doe',
      phone: '555-1234',
      password: 'password123'
    }
  end

  let(:user) { create(:user, phone: '555-9999', password: BCrypt::Password.create('password123')) }
  let(:jwt_secret) { ENV['JWT_SECRET'] || 'your_jwt_secret' }
  let(:valid_token) do
    JWT.encode(
      { 
        id: user.id, 
        name: user.name, 
        phone: user.phone,
        exp: 1.day.from_now.to_i
      }, 
      jwt_secret
    )
  end
  let(:auth_headers) { { 'Authorization' => "Bearer #{valid_token}" } }

  describe 'POST /api/users/register' do
    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post '/api/users/register', params: valid_user_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include('name' => 'John Doe')
      end
    end

    context 'with missing parameters' do
      it 'returns error when name is missing' do
        post '/api/users/register', params: valid_user_params.except(:name)
        
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['message']).to eq('Name, phone, and password are required.')
      end

      it 'returns error when phone is missing' do
        post '/api/users/register', params: valid_user_params.except(:phone)
        
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['message']).to eq('Name, phone, and password are required.')
      end
    end

    context 'with duplicate phone' do
      it 'returns error when phone already exists' do
        create(:user, phone: '555-1234')
        
        post '/api/users/register', params: valid_user_params
        
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['message']).to eq('User already exists.')
      end
    end
  end

  describe 'POST /api/users/login' do
    let!(:existing_user) { create(:user, phone: '555-1234', password: BCrypt::Password.create('password123')) }

    context 'with valid credentials' do
      it 'returns token and user data' do
        post '/api/users/login', params: { phone: '555-1234', password: 'password123' }
        
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('token')
        expect(response_body['user']['phone']).to eq('555-1234')
      end
    end

    context 'with invalid credentials' do
      it 'returns error for wrong password' do
        post '/api/users/login', params: { phone: '555-1234', password: 'wrongpassword' }
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq('Invalid phone or password.')
      end

      it 'returns error for non-existent user' do
        post '/api/users/login', params: { phone: '555-9999', password: 'password123' }
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq('Invalid phone or password.')
      end
    end
  end

  describe 'GET /api/users/current' do
    context 'with valid token' do
      it 'returns current user data' do
        get '/api/users/current', headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['user']['id']).to eq(user.id)
      end
    end

    context 'without token' do
      it 'returns unauthorized error' do
        get '/api/users/current'
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq('Access token required.')
      end
    end
  end

  describe 'POST /api/users/change-password' do
    context 'with valid parameters' do
      it 'changes user password' do
        post '/api/users/change-password', 
             params: { oldPassword: 'password123', newPassword: 'newpassword123' },
             headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Password changed successfully.')
      end
    end

    context 'with wrong old password' do
      it 'returns error' do
        post '/api/users/change-password', 
             params: { oldPassword: 'wrongpassword', newPassword: 'newpassword123' },
             headers: auth_headers
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq('Old password is incorrect.')
      end
    end
  end

  describe 'POST /api/users/change-phone' do
    context 'with valid parameters' do
      it 'updates phone number' do
        post '/api/users/change-phone', 
             params: { newPhone: '555-8888', password: 'password123' },
             headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Phone number updated successfully.')
        expect(JSON.parse(response.body)['user']['phone']).to eq('555-8888')
      end
    end

    context 'with phone already in use' do
      it 'returns error' do
        create(:user, phone: '555-7777')
        
        post '/api/users/change-phone', 
             params: { newPhone: '555-7777', password: 'password123' },
             headers: auth_headers
        
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['message']).to eq('Phone number already in use.')
      end
    end
  end
end