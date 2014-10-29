module Admin
  class SocialEventsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    authorize_resource :social_event, through: :conference

    def show
      render :social_events_list
    end

    def update
      if @conference.update_attributes(params[:conference])
        redirect_to admin_conference_social_events_path(conference_id: @conference.short_title),
                    notice: 'Social events were successfully updated.'
      else
        redirect_to admin_conference_social_events_path(conference_id: @conference.short_title),
                    error: "Social events update failed.
                            #{@conference.errors.full_messages.join('. '}")
      end
    end
  end
end
