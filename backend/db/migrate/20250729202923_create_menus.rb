class CreateMenus < ActiveRecord::Migration[8.0]
  def change
    create_table :menus do |t|
      t.string :name, null: false
      t.text :ingredients
      t.decimal :price, null: false, precision: 10, scale: 2
      t.string :image
      t.boolean :available, default: true
      t.boolean :out_of_stock, default: false
      t.string :badge
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
