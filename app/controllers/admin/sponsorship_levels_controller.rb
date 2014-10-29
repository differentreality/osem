module Admin
  class SponsorshipLevelsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    authorize_resource through: :conference

    def index
      authorize! :index, SponsorshipLevel.new(conference_id: @conference.id)
    end

    def update
      if @conference.update_attributes(params[:conference])
        redirect_to(admin_conference_sponsorship_levels_path(
                    conference_id: @conference.short_title),
                    notice: 'Sponsorship levels were successfully updated.')
      else
        redirect_to(admin_conference_sponsorship_levels_path(
                    conference_id: @conference.short_title),
                    error: "Sponsorship levels update failed:
                            #{@conference.errors.full_messages.join('. ')}")
      end
    end
  end
end
