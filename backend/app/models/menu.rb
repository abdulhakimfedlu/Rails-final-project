class Menu < ApplicationRecord
  belongs_to :category
  has_many :ratings, dependent: :destroy
  
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :badge, inclusion: { in: ['New', 'Popular', 'Recommended', 'Vegan', ''] }, allow_blank: true
end
