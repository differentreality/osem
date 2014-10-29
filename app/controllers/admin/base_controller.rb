module Admin
  class BaseController < ApplicationController
    before_filter :verify_user_admin

    def verify_user_admin
      if (current_user.nil?)
        redirect_to new_user_session_path
        return false
      end
      # Do not allow acces sto admin area at all
      # Unless the user has an appropriate role (organizer, cfp, info_desk, volunteers_coordinator)
      # or the user is an admin.
      # Add a check for all available roles that grant access to the admin area (or any part of it).
      unless (current_user.has_role? :organizer, :any) ||
             (current_user.has_role? :cfp, :any) ||
             (current_user.has_role? :info_desk, :any) ||
             (current_user.has_role? :volunteers_coordinator, :any) ||
             current_user.is_admin
        raise CanCan::AccessDenied.new('You are not authorized to access this area!')
      end
    end
  end
end
