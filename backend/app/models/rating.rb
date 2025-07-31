class Rating < ApplicationRecord
  belongs_to :menu
  
  validates :stars, presence: true, inclusion: { in: 1..5 }
end
