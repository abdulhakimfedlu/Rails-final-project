require 'rails_helper'

RSpec.describe 'Api::Employees', type: :request do
  let(:user) { create(:user) }
  let(:jwt_secret) { ENV['JWT_SECRET'] || 'your_jwt_secret' }
  let(:valid_token) do
    JWT.encode({ id: user.id, exp: 1.day.from_now.to_i }, jwt_secret)
  end
  let(:auth_headers) { { 'Authorization' => "Bearer #{valid_token}" } }

  let(:valid_employee_params) do
    {
      name: 'Jane Smith',
      phone: '555-1234',
      position: 'waiter',
      salary: 35000,
      tableAssigned: 'Table 5',
      description: 'Experienced waiter',
      workingHour: '9 AM - 5 PM'
    }
  end

  describe 'GET /api/employees' do
    context 'with valid authentication' do
      it 'returns all employees' do
        employee1 = create(:employee, name: 'John Doe', position: 'waiter')
        employee2 = create(:employee, name: 'Jane Smith', position: 'cashier')
        
        get '/api/employees', headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body.length).to eq(2)
        expect(response_body.map { |e| e['name'] }).to contain_exactly('John Doe', 'Jane Smith')
      end

      it 'returns empty array when no employees exist' do
        get '/api/employees', headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        get '/api/employees'
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/employees/:id' do
    let(:employee) { create(:employee, name: 'John Doe') }

    context 'with valid authentication' do
      it 'returns specific employee' do
        get "/api/employees/#{employee.id}", headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body['name']).to eq('John Doe')
        expect(response_body['_id']).to eq(employee.id)
      end

      it 'returns error for non-existent employee' do
        get '/api/employees/999', headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('Employee not found')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        get "/api/employees/#{employee.id}"
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/employees' do
    context 'with valid authentication' do
      it 'creates a new employee' do
        expect {
          post '/api/employees', params: valid_employee_params, headers: auth_headers
        }.to change(Employee, :count).by(1)

        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body['name']).to eq('Jane Smith')
        expect(response_body['position']).to eq('waiter')
        expect(response_body['tableAssigned']).to eq('Table 5')
        expect(response_body['status']).to eq('active')
      end

      it 'creates employee without table assignment for non-waiter positions' do
        cashier_params = valid_employee_params.merge(position: 'cashier').except(:tableAssigned)
        
        post '/api/employees', params: cashier_params, headers: auth_headers
        
        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body['position']).to eq('cashier')
        expect(response_body['tableAssigned']).to be_nil
      end

      it 'sets default values correctly' do
        minimal_params = { name: 'Test Employee', phone: '555-9999', position: 'cashier', salary: 30000 }
        
        post '/api/employees', params: minimal_params, headers: auth_headers
        
        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body['status']).to eq('active')
        expect(response_body['reasonForLeaving']).to eq('')
        expect(response_body).to have_key('dateHired')
      end

      it 'returns error for invalid employee data' do
        invalid_params = valid_employee_params.merge(salary: -1000, position: 'invalid_position')
        
        post '/api/employees', params: invalid_params, headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        post '/api/employees', params: valid_employee_params
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /api/employees/:id' do
    let(:employee) { create(:employee, name: 'Old Name', position: 'waiter', table_assigned: 'Table 1') }

    context 'with valid authentication' do
      it 'updates employee information' do
        update_params = {
          name: 'Updated Name',
          position: 'manager',
          salary: 50000,
          status: 'active'
        }
        
        put "/api/employees/#{employee.id}", params: update_params, headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body['name']).to eq('Updated Name')
        expect(response_body['position']).to eq('manager')
        expect(response_body['salary']).to eq(50000)
        expect(response_body['tableAssigned']).to be_nil # Should be nil for non-waiter
      end

      it 'handles position change from waiter to non-waiter' do
        put "/api/employees/#{employee.id}", 
            params: { position: 'cashier' }, 
            headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body['position']).to eq('cashier')
        expect(response_body['tableAssigned']).to be_nil
      end

      it 'handles position change to waiter with table assignment' do
        non_waiter = create(:employee, position: 'cashier', table_assigned: nil)
        
        put "/api/employees/#{non_waiter.id}", 
            params: { position: 'waiter', tableAssigned: 'Table 3' }, 
            headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body['position']).to eq('waiter')
        expect(response_body['tableAssigned']).to eq('Table 3')
      end

      it 'returns error for non-existent employee' do
        put '/api/employees/999', params: { name: 'Updated' }, headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('Employee not found')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        put "/api/employees/#{employee.id}", params: { name: 'Updated' }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/employees/:id' do
    let!(:employee) { create(:employee) }

    context 'with valid authentication' do
      it 'deletes employee' do
        expect {
          delete "/api/employees/#{employee.id}", headers: auth_headers
        }.to change(Employee, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Employee deleted')
      end

      it 'returns error for non-existent employee' do
        delete '/api/employees/999', headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('Employee not found')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        delete "/api/employees/#{employee.id}"
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end