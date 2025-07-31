require 'rails_helper'

RSpec.describe 'Api::Ratings', type: :request do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:menu) { create(:menu, category: category) }
  let(:jwt_secret) { ENV['JWT_SECRET'] || 'your_jwt_secret' }
  let(:valid_token) do
    JWT.encode({ id: user.id, exp: 1.day.from_now.to_i }, jwt_secret)
  end
  let(:auth_headers) { { 'Authorization' => "Bearer #{valid_token}" } }

  describe 'POST /api/ratings' do
    it 'creates a new rating without authentication' do
      expect {
        post '/api/ratings', params: { menu: menu.id, stars: 4 }
      }.to change(Rating, :count).by(1)

      expect(response).to have_http_status(:created)
      response_body = JSON.parse(response.body)
      expect(response_body['menu_id']).to eq(menu.id)
      expect(response_body['stars']).to eq(4)
    end

    it 'returns error for missing parameters' do
      post '/api/ratings', params: { menu: menu.id }
      
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['message']).to eq('Menu and stars are required.')
    end

    it 'returns error for invalid star rating' do
      post '/api/ratings', params: { menu: menu.id, stars: 6 }
      
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('errors')
    end

    it 'returns error for non-existent menu' do
      post '/api/ratings', params: { menu: 999, stars: 4 }
      
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('errors')
    end
  end

  describe 'GET /api/ratings/menu/:menu_id' do
    context 'with valid authentication' do
      it 'returns all ratings for a menu' do
        rating1 = create(:rating, menu: menu, stars: 4)
        rating2 = create(:rating, menu: menu, stars: 5)
        other_menu = create(:menu, category: category)
        create(:rating, menu: other_menu, stars: 3)
        
        get "/api/ratings/menu/#{menu.id}", headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body.length).to eq(2)
        expect(response_body.map { |r| r['stars'] }).to contain_exactly(4, 5)
      end

      it 'returns empty array for menu with no ratings' do
        get "/api/ratings/menu/#{menu.id}", headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        get "/api/ratings/menu/#{menu.id}"
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/ratings/menu/:menu_id/average' do
    it 'returns average rating without authentication' do
      create(:rating, menu: menu, stars: 4)
      create(:rating, menu: menu, stars: 5)
      create(:rating, menu: menu, stars: 3)
      
      get "/api/ratings/menu/#{menu.id}/average"
      
      expect(response).to have_http_status(:ok)
      response_body = JSON.parse(response.body)
      expect(response_body['avgRating']).to eq(4.0)
      expect(response_body['count']).to eq(3)
    end

    it 'returns zero average for menu with no ratings' do
      get "/api/ratings/menu/#{menu.id}/average"
      
      expect(response).to have_http_status(:ok)
      response_body = JSON.parse(response.body)
      expect(response_body['avgRating']).to eq(0)
      expect(response_body['count']).to eq(0)
    end

    it 'calculates correct average for single rating' do
      create(:rating, menu: menu, stars: 5)
      
      get "/api/ratings/menu/#{menu.id}/average"
      
      expect(response).to have_http_status(:ok)
      response_body = JSON.parse(response.body)
      expect(response_body['avgRating']).to eq(5.0)
      expect(response_body['count']).to eq(1)
    end
  end
end