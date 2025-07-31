require 'rails_helper'

RSpec.describe Menu, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      menu = build(:menu)
      expect(menu).to be_valid
    end

    it 'requires a name' do
      menu = build(:menu, name: nil)
      expect(menu).not_to be_valid
      expect(menu.errors[:name]).to include("can't be blank")
    end

    it 'requires a price' do
      menu = build(:menu, price: nil)
      expect(menu).not_to be_valid
      expect(menu.errors[:price]).to include("can't be blank")
    end

    it 'requires price to be greater than or equal to 0' do
      menu = build(:menu, price: -1)
      expect(menu).not_to be_valid
      expect(menu.errors[:price]).to include("must be greater than or equal to 0")
    end

    it 'allows price of 0' do
      menu = build(:menu, price: 0)
      expect(menu).to be_valid
    end

    it 'validates badge inclusion' do
      valid_badges = ['New', 'Popular', 'Recommended', 'Vegan', '']
      
      valid_badges.each do |badge|
        menu = build(:menu, badge: badge)
        expect(menu).to be_valid
      end

      menu = build(:menu, badge: 'Invalid')
      expect(menu).not_to be_valid
      expect(menu.errors[:badge]).to include("is not included in the list")
    end

    it 'allows blank badge' do
      menu = build(:menu, badge: nil)
      expect(menu).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to category' do
      association = Menu.reflect_on_association(:category)
      expect(association.macro).to eq :belongs_to
    end

    it 'has many ratings' do
      association = Menu.reflect_on_association(:ratings)
      expect(association.macro).to eq :has_many
    end

    it 'destroys associated ratings when deleted' do
      menu = create(:menu)
      rating = create(:rating, menu: menu)
      
      expect { menu.destroy }.to change { Rating.count }.by(-1)
    end
  end
end