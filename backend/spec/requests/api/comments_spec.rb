require 'rails_helper'

RSpec.describe 'Api::Comments', type: :request do
  let(:user) { create(:user) }
  let(:jwt_secret) { ENV['JWT_SECRET'] || 'your_jwt_secret' }
  let(:valid_token) do
    JWT.encode({ id: user.id, exp: 1.day.from_now.to_i }, jwt_secret)
  end
  let(:auth_headers) { { 'Authorization' => "Bearer #{valid_token}" } }

  describe 'POST /api/comments' do
    context 'with non-anonymous comment' do
      let(:valid_comment_params) do
        {
          name: 'John Doe',
          phone: '555-1234',
          comment: 'Great service!',
          anonymous: false
        }
      end

      it 'creates a new comment without authentication' do
        expect {
          post '/api/comments', params: valid_comment_params
        }.to change(Comment, :count).by(1)

        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body['success']).to be true
        expect(response_body['message']).to eq('Comment submitted successfully')
        expect(response_body['comment']['name']).to eq('John Doe')
        expect(response_body['comment']['anonymous']).to be false
      end

      it 'returns error when name is missing for non-anonymous comment' do
        post '/api/comments', params: valid_comment_params.except(:name)
        
        expect(response).to have_http_status(:bad_request)
        response_body = JSON.parse(response.body)
        expect(response_body['success']).to be false
        expect(response_body['message']).to eq('Name and phone are required if not anonymous.')
      end

      it 'returns error when phone is missing for non-anonymous comment' do
        post '/api/comments', params: valid_comment_params.except(:phone)
        
        expect(response).to have_http_status(:bad_request)
        response_body = JSON.parse(response.body)
        expect(response_body['success']).to be false
        expect(response_body['message']).to eq('Name and phone are required if not anonymous.')
      end
    end

    context 'with anonymous comment' do
      let(:anonymous_comment_params) do
        {
          comment: 'Anonymous feedback',
          anonymous: true
        }
      end

      it 'creates anonymous comment without name and phone' do
        expect {
          post '/api/comments', params: anonymous_comment_params
        }.to change(Comment, :count).by(1)

        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body['success']).to be true
        expect(response_body['comment']['name']).to eq('')
        expect(response_body['comment']['phone']).to eq('')
        expect(response_body['comment']['anonymous']).to be true
      end

      it 'ignores provided name and phone for anonymous comment' do
        params = anonymous_comment_params.merge(name: 'Should be ignored', phone: '555-9999')
        
        post '/api/comments', params: params
        
        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body['comment']['name']).to eq('')
        expect(response_body['comment']['phone']).to eq('')
      end
    end

    it 'returns error for missing comment text' do
      post '/api/comments', params: { name: 'John', phone: '555-1234', anonymous: false }
      
      expect(response).to have_http_status(:internal_server_error)
      response_body = JSON.parse(response.body)
      expect(response_body['success']).to be false
      expect(response_body['message']).to eq('Failed to submit comment')
    end
  end

  describe 'GET /api/comments' do
    it 'returns all comments without authentication' do
      comment1 = create(:comment, comment: 'First comment', name: 'John', anonymous: false)
      comment2 = create(:comment, comment: 'Second comment', name: '', anonymous: true)
      
      get '/api/comments'
      
      expect(response).to have_http_status(:ok)
      response_body = JSON.parse(response.body)
      expect(response_body['success']).to be true
      expect(response_body['comments'].length).to eq(2)
      
      # Comments should be ordered by created_at desc (newest first)
      expect(response_body['comments'].first['comment']).to eq('Second comment')
      expect(response_body['comments'].last['comment']).to eq('First comment')
    end

    it 'returns empty array when no comments exist' do
      get '/api/comments'
      
      expect(response).to have_http_status(:ok)
      response_body = JSON.parse(response.body)
      expect(response_body['success']).to be true
      expect(response_body['comments']).to eq([])
    end

    it 'includes all comment fields in response' do
      comment = create(:comment, 
                      comment: 'Test comment', 
                      name: 'Jane Doe', 
                      phone: '555-5678',
                      anonymous: false)
      
      get '/api/comments'
      
      expect(response).to have_http_status(:ok)
      response_body = JSON.parse(response.body)
      comment_data = response_body['comments'].first
      
      expect(comment_data).to include(
        '_id' => comment.id,
        'name' => 'Jane Doe',
        'phone' => '555-5678',
        'comment' => 'Test comment',
        'anonymous' => false
      )
      expect(comment_data).to have_key('createdAt')
      expect(comment_data).to have_key('updatedAt')
    end
  end
end