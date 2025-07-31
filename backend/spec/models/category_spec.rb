require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      category = build(:category)
      expect(category).to be_valid
    end

    it 'requires a name' do
      category = build(:category, name: nil)
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end

    it 'requires a unique name' do
      create(:category, name: "Appetizers")
      category = build(:category, name: "Appetizers")
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("has already been taken")
    end
  end

  describe 'associations' do
    it 'has many menus' do
      association = Category.reflect_on_association(:menus)
      expect(association.macro).to eq :has_many
    end

    it 'destroys associated menus when deleted' do
      category = create(:category)
      menu = create(:menu, category: category)
      
      expect { category.destroy }.to change { Menu.count }.by(-1)
    end
  end
end