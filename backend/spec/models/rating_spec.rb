require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      rating = build(:rating)
      expect(rating).to be_valid
    end

    it 'requires stars' do
      rating = build(:rating, stars: nil)
      expect(rating).not_to be_valid
      expect(rating.errors[:stars]).to include("can't be blank")
    end

    it 'validates stars inclusion between 1 and 5' do
      (1..5).each do |star_count|
        rating = build(:rating, stars: star_count)
        expect(rating).to be_valid
      end

      [0, 6, -1, 10].each do |invalid_stars|
        rating = build(:rating, stars: invalid_stars)
        expect(rating).not_to be_valid
        expect(rating.errors[:stars]).to include("is not included in the list")
      end
    end
  end

  describe 'associations' do
    it 'belongs to menu' do
      association = Rating.reflect_on_association(:menu)
      expect(association.macro).to eq :belongs_to
    end
  end
end