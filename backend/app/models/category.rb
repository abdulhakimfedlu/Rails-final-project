class Category < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  
  has_many :menus, dependent: :destroy
end
