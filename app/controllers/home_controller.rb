class HomeController < ApplicationController

  def root
    case
      when current_user == nil
        redirect_to login_path
      else
        redirect_to new_submit_path
    end
  end

end
