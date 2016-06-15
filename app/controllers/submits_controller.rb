class SubmitsController < ApplicationController

  before_action :logged_in_user, only: [:show, :index, :edit, :update]

  def new
    @nr_of_people = Prospect.where(recommender_id: current_user.id).count

    @here = get_directory
  end

  def create
    current_user.update_attribute(:submitted, true)
    #flash[:alert] = "Your submission was succesful!"
    render 'new'

  end

  def get_directory
    user_college = 'null'
    emails = University.pluck(:name)
    user_email = current_user.email
    for email_allowed in emails
      if user_email.include? email_allowed
        user_college = email_allowed
      end
    end
    if user_college == 'null'
      here = 'http://google.com'
    else
      here = 'http://' + University.find_by(name:user_college).directory
    end
  end

end
