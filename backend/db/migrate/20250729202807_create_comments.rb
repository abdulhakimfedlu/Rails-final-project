class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.string :name, default: ''
      t.string :phone, default: ''
      t.text :comment, null: false
      t.boolean :anonymous, default: false

      t.timestamps
    end
  end
end
