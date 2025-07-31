class User < ApplicationRecord
  validates :name, presence: true
  validates :phone, presence: true, uniqueness: true
  validates :password, presence: true
end
