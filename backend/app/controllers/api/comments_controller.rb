class Api::CommentsController < ApplicationController
  before_action :authenticate_user, except: [:create, :index]
  
  # Create a new comment
  def create
    name = params[:name]
    phone = params[:phone]
    comment = params[:comment]
    anonymous = params[:anonymous] == true || params[:anonymous] == 'true'

    # Validation: if not anonymous, name and phone are required
    if !anonymous && (name.blank? || phone.blank?)
      return render_error('Name and phone are required if not anonymous.')
    end

    # For anonymous comments, clear name and phone
    if anonymous
      name = ''
      phone = ''
    end

    new_comment = Comment.new(
      name: name,
      phone: phone,
      comment: comment,
      anonymous: anonymous
    )

    if new_comment.save
      render_success({ comment: format_comment(new_comment) }, 'Comment submitted successfully', :created)
    else
      render_error('Failed to submit comment', :unprocessable_entity, new_comment.errors.full_messages)
    end
  end

  # Get all comments
  def index
    comments = Comment.order(created_at: :desc).map { |comment| format_comment(comment) }
    render_success({ comments: comments })
  end
end