require 'rails_helper'

RSpec.describe 'Api::Categories', type: :request do
  let(:user) { create(:user) }
  let(:jwt_secret) { ENV['JWT_SECRET'] || 'your_jwt_secret' }
  let(:valid_token) do
    JWT.encode({ id: user.id, exp: 1.day.from_now.to_i }, jwt_secret)
  end
  let(:auth_headers) { { 'Authorization' => "Bearer #{valid_token}" } }

  describe 'GET /api/categories' do
    it 'returns all categories without authentication' do
      category1 = create(:category, name: 'Appetizers')
      category2 = create(:category, name: 'Main Courses')
      
      get '/api/categories'
      
      expect(response).to have_http_status(:ok)
      response_body = JSON.parse(response.body)
      expect(response_body.length).to eq(2)
      expect(response_body.first['name']).to eq('Appetizers')
    end

    it 'returns empty array when no categories exist' do
      get '/api/categories'
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe 'POST /api/categories' do
    context 'with valid authentication' do
      it 'creates a new category' do
        expect {
          post '/api/categories', params: { name: 'Desserts' }, headers: auth_headers
        }.to change(Category, :count).by(1)

        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body['name']).to eq('Desserts')
        expect(response_body).to have_key('_id')
      end

      it 'returns error for duplicate category name' do
        create(:category, name: 'Appetizers')
        
        post '/api/categories', params: { name: 'Appetizers' }, headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        post '/api/categories', params: { name: 'Desserts' }
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq('Access token required.')
      end
    end
  end

  describe 'PUT /api/categories/:id' do
    let(:category) { create(:category, name: 'Old Name') }

    context 'with valid authentication' do
      it 'updates category name' do
        put "/api/categories/#{category.id}", 
            params: { name: 'New Name' }, 
            headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body['name']).to eq('New Name')
        expect(category.reload.name).to eq('New Name')
      end

      it 'returns error for non-existent category' do
        put '/api/categories/999', 
            params: { name: 'New Name' }, 
            headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('Category not found')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        put "/api/categories/#{category.id}", params: { name: 'New Name' }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/categories/:id' do
    let!(:category) { create(:category) }
    let!(:menu) { create(:menu, category: category) }

    context 'with valid authentication' do
      it 'deletes category and associated menus' do
        expect {
          delete "/api/categories/#{category.id}", headers: auth_headers
        }.to change(Category, :count).by(-1).and change(Menu, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Category and related menu items deleted')
      end

      it 'returns error for non-existent category' do
        delete '/api/categories/999', headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('Category not found')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        delete "/api/categories/#{category.id}"
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end