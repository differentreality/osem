module Admin
  class TargetsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    authorize_resource through: :conference

    def index
      authorize! :index, Target.new(conference_id: @conference.id)
    end

    def update
      authorize! :update, @conference => Target

      if @conference.update_attributes(params[:conference])
        redirect_to(admin_conference_targets_path(
                    conference_id: @conference.short_title),
                    notice: 'Targets were successfully updated.')
      else
        redirect_to(admin_conference_targets_path(
                    conference_id: @conference.short_title),
                    error: 'Targets update failed: ' \
                    "#{@conference.errors.full_messages.join('. ')}")
      end
    end
  end
end
