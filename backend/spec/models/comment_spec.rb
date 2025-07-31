require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      comment = build(:comment)
      expect(comment).to be_valid
    end

    it 'requires a comment' do
      comment = build(:comment, comment: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:comment]).to include("can't be blank")
    end

    it 'does not allow empty comment' do
      comment = build(:comment, comment: "")
      expect(comment).not_to be_valid
      expect(comment.errors[:comment]).to include("can't be blank")
    end
  end
end