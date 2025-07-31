class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :name, null: false
      t.string :phone, null: false
      t.string :image
      t.string :position, null: false
      t.decimal :salary, null: false, precision: 10, scale: 2
      t.datetime :date_hired, default: -> { 'CURRENT_TIMESTAMP' }
      t.string :table_assigned
      t.text :description, default: ''
      t.string :working_hour, default: ''
      t.string :status, default: 'active'
      t.text :reason_for_leaving, default: ''

      t.timestamps
    end
    
    add_index :employees, :phone, unique: true
  end
end
