require 'rails_helper'

RSpec.describe Employee, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      employee = build(:employee)
      expect(employee).to be_valid
    end

    it 'requires a name' do
      employee = build(:employee, name: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:name]).to include("can't be blank")
    end

    it 'requires a phone' do
      employee = build(:employee, phone: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:phone]).to include("can't be blank")
    end

    it 'requires a unique phone' do
      create(:employee, phone: "555-1234")
      employee = build(:employee, phone: "555-1234")
      expect(employee).not_to be_valid
      expect(employee.errors[:phone]).to include("has already been taken")
    end

    it 'requires a position' do
      employee = build(:employee, position: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:position]).to include("can't be blank")
    end

    it 'validates position inclusion' do
      valid_positions = ['waiter', 'cashier', 'manager', 'baresta', 'chaf', 'janitor/cleaner', 'pastry chef']
      
      valid_positions.each do |position|
        employee = build(:employee, position: position, table_assigned: position == 'waiter' ? 'Table 1' : nil)
        expect(employee).to be_valid
      end

      employee = build(:employee, position: 'invalid_position')
      expect(employee).not_to be_valid
      expect(employee.errors[:position]).to include("is not included in the list")
    end

    it 'requires a salary' do
      employee = build(:employee, salary: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:salary]).to include("can't be blank")
    end

    it 'requires salary to be greater than or equal to 0' do
      employee = build(:employee, salary: -1)
      expect(employee).not_to be_valid
      expect(employee.errors[:salary]).to include("must be greater than or equal to 0")
    end

    it 'allows salary of 0' do
      employee = build(:employee, salary: 0, position: 'cashier', table_assigned: nil)
      expect(employee).to be_valid
    end

    it 'requires table_assigned for waiters' do
      employee = build(:employee, position: 'waiter', table_assigned: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:table_assigned]).to include("can't be blank")
    end

    it 'does not require table_assigned for non-waiters' do
      employee = build(:employee, position: 'cashier', table_assigned: nil)
      expect(employee).to be_valid
    end

    it 'validates status inclusion' do
      valid_statuses = ['active', 'fired', 'resigned']
      
      valid_statuses.each do |status|
        employee = build(:employee, status: status)
        expect(employee).to be_valid
      end

      employee = build(:employee, status: 'invalid_status')
      expect(employee).not_to be_valid
      expect(employee.errors[:status]).to include("is not included in the list")
    end
  end

  describe '#terminate_employment' do
    let(:employee) { create(:employee) }

    it 'terminates employment with fired status' do
      employee.terminate_employment('fired', 'Performance issues')
      
      expect(employee.status).to eq('fired')
      expect(employee.reason_for_leaving).to eq('Performance issues')
    end

    it 'terminates employment with resigned status' do
      employee.terminate_employment('resigned', 'Better opportunity')
      
      expect(employee.status).to eq('resigned')
      expect(employee.reason_for_leaving).to eq('Better opportunity')
    end

    it 'raises error for invalid status' do
      expect {
        employee.terminate_employment('invalid', 'Some reason')
      }.to raise_error(ArgumentError, 'Invalid status. Must be "fired" or "resigned".')
    end
  end
end