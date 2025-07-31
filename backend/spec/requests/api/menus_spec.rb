require 'rails_helper'

RSpec.describe 'Api::Menus', type: :request do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:jwt_secret) { ENV['JWT_SECRET'] || 'your_jwt_secret' }
  let(:valid_token) do
    JWT.encode({ id: user.id, exp: 1.day.from_now.to_i }, jwt_secret)
  end
  let(:auth_headers) { { 'Authorization' => "Bearer #{valid_token}" } }

  describe 'GET /api/menus/category/:category_id' do
    it 'returns menus for a specific category without authentication' do
      menu1 = create(:menu, category: category, name: 'Burger')
      menu2 = create(:menu, category: category, name: 'Pizza')
      other_category = create(:category)
      create(:menu, category: other_category, name: 'Salad')
      
      get "/api/menus/category/#{category.id}"
      
      expect(response).to have_http_status(:ok)
      response_body = JSON.parse(response.body)
      expect(response_body.length).to eq(2)
      expect(response_body.map { |m| m['name'] }).to contain_exactly('Burger', 'Pizza')
    end

    it 'returns empty array for category with no menus' do
      get "/api/menus/category/#{category.id}"
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe 'POST /api/menus/category/:category_id' do
    let(:valid_menu_params) do
      {
        name: 'Delicious Burger',
        ingredients: 'Beef, Lettuce, Tomato',
        price: 12.99,
        badge: 'New'
      }
    end

    context 'with valid authentication' do
      it 'creates a new menu item' do
        expect {
          post "/api/menus/category/#{category.id}", 
               params: valid_menu_params, 
               headers: auth_headers
        }.to change(Menu, :count).by(1)

        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body['name']).to eq('Delicious Burger')
        expect(response_body['category_id']).to eq(category.id)
        expect(response_body['badge']).to eq('New')
      end

      it 'sets default values correctly' do
        post "/api/menus/category/#{category.id}", 
             params: { name: 'Simple Dish', price: 10.0 }, 
             headers: auth_headers
        
        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body['available']).to be true
        expect(response_body['outOfStock']).to be false
      end

      it 'returns error for invalid menu data' do
        post "/api/menus/category/#{category.id}", 
             params: { name: '', price: -5 }, 
             headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        post "/api/menus/category/#{category.id}", params: valid_menu_params
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /api/menus/:id' do
    let(:menu) { create(:menu, category: category, name: 'Old Name', price: 10.0) }

    context 'with valid authentication' do
      it 'updates menu item' do
        put "/api/menus/#{menu.id}", 
            params: { name: 'Updated Name', price: 15.0, badge: 'Popular' }, 
            headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body['name']).to eq('Updated Name')
        expect(response_body['price']).to eq(15.0)
        expect(response_body['badge']).to eq('Popular')
      end

      it 'returns error for non-existent menu' do
        put '/api/menus/999', 
            params: { name: 'Updated Name' }, 
            headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('Menu item not found')
      end

      it 'handles availability and stock status' do
        put "/api/menus/#{menu.id}", 
            params: { available: false, outOfStock: true }, 
            headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body['available']).to be false
        expect(response_body['outOfStock']).to be true
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        put "/api/menus/#{menu.id}", params: { name: 'Updated Name' }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/menus/:id' do
    let!(:menu) { create(:menu, category: category) }

    context 'with valid authentication' do
      it 'deletes menu item' do
        expect {
          delete "/api/menus/#{menu.id}", headers: auth_headers
        }.to change(Menu, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Menu item deleted')
      end

      it 'returns error for non-existent menu' do
        delete '/api/menus/999', headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('Menu item not found')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        delete "/api/menus/#{menu.id}"
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end