class Employee < ApplicationRecord
  validates :name, presence: true
  validates :phone, presence: true, uniqueness: true
  validates :position, presence: true, inclusion: { in: ['waiter', 'cashier', 'manager', 'baresta', 'chaf', 'janitor/cleaner', 'pastry chef'] }
  validates :salary, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :table_assigned, presence: true, if: -> { position == 'waiter' }
  validates :status, inclusion: { in: ['active', 'fired', 'resigned'] }

  # Method to terminate employment (equivalent to terminateEmployment in Node.js)
  def terminate_employment(status, reason)
    unless ['fired', 'resigned'].include?(status)
      raise ArgumentError, 'Invalid status. Must be "fired" or "resigned".'
    end
    
    self.status = status
    self.reason_for_leaving = reason
    save!
  end
end
