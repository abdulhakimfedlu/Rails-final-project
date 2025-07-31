RSpec.shared_examples 'requires authentication' do |method, path, params = {}|
  it 'returns unauthorized when no token provided' do
    send(method, path, params: params)
    expect(response).to have_http_status(:unauthorized)
    expect(json_response['message']).to eq('Access token required.')
  end

  it 'returns unauthorized when invalid token provided' do
    headers = { 'Authorization' => 'Bearer invalid_token' }
    send(method, path, params: params, headers: headers)
    expect(response).to have_http_status(:unauthorized)
    expect(json_response['message']).to eq('Invalid token.')
  end
end

RSpec.shared_examples 'returns not found' do |resource_name = 'resource'|
  it "returns not found for non-existent #{resource_name}" do
    expect(response).to have_http_status(:not_found)
    expect(json_response['message']).to include('not found')
  end
end

RSpec.shared_examples 'validates required fields' do |fields|
  fields.each do |field|
    it "returns error when #{field} is missing" do
      expect(response).to have_http_status(:bad_request)
      expect(json_response['message']).to include(field.to_s)
    end
  end
end