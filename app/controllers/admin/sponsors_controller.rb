# frozen_string_literal: true

module Admin
  class SponsorsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :sponsor, through: :conference
    before_action :sponsorship_level_required, only: [:index, :new]

    def index
      authorize! :index, Sponsor.new(conference_id: @conference.id)
    end

    def edit; end

    def new
      @sponsor = @conference.sponsors.new
    end

    def create
      @sponsor = @conference.sponsors.new(sponsor_params)
      if @sponsor.save
        redirect_to admin_conference_sponsors_path(conference_id: @conference.short_title),
                    notice: 'Sponsor successfully created.'
      else
        flash.now[:error] = "Creating sponsor failed: #{@sponsor.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      sponsor_params[:shipments].reject!{ |shipment| shipment['carrier'].blank? } if sponsor_params[:shipments]
      Rails.logger.debug "sponsor_params: #{sponsor_params}"
      # if @sponsor.update_attributes(sponsor_params.map{ |k, v| if k == :shipments then [k,v.reject{|shipment| shipment['carrier'].blank?}]; else Hash[*[k,v]]; end })
      if @sponsor.update_attributes(sponsor_params)
        respond_to do |format|
          format.html {
            redirect_to admin_conference_sponsors_path(
                        conference_id: @conference.short_title),
                        notice: 'Sponsor successfully updated.'
          }
          format.js { head :ok }
        end
      else
        flash.now[:error] = "Update sponsor failed: #{@sponsor.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @sponsor.destroy
        redirect_to admin_conference_sponsors_path(conference_id: @conference.short_title),
                    notice: 'Sponsor successfully deleted.'
      else
        redirect_to admin_conference_sponsors_path(conference_id: @conference.short_title),
                    error: 'Deleting sponsor failed! ' \
                    "#{@sponsor.errors.full_messages.join('. ')}."
      end
    end

    def add_swag_fields
      respond_to do |format|
        format.js
      end
    end

    def add_shipment

    end

    def add_shipment_fields
      respond_to do |format|
        format.js
      end
    end

    def confirm
      @sponsor.confirm!

      if @sponsor.save
        redirect_to admin_conference_sponsors_path(@conference.short_title),
                      notice: 'Sponsor successfully confirmed!'
      else
        flash[:error] = 'Sponsor couldn\' t be confirmed.'
      end
    end

    def cancel
      @sponsor.cancel!

      if @sponsor.save
        redirect_to admin_conference_sponsors_path(@conference.short_title),
                      notice: 'Sponsor successfully canceled'
      else
        flash[:error] = 'Sponsor couldn\'t be canceled'
      end
    end


    def remove_field
      respond_to do |format|
        format.js
      end
    end

    private

    def sponsor_params
      params.require(:sponsor).permit(:name, :description, :website_url,
                                      :picture, :picture_cache,
                                      :sponsorship_level_id,
                                      :conference_id,
                                      :has_swag, :has_banner,
                                      swag: [:type, :quantity, :delivered, :available],
                                      shipments: [:carrier,
                                                  :track_no,
                                                  :boxes,
                                                  :swag] )
    end

    def shipment_params
      params.require(:sponsor).require(:shipment).permit([:carrier,
                                                          :track_no,
                                                          :boxes,
                                                          :swag])
    end

    def sponsorship_level_required
      return unless @conference.sponsorship_levels.empty?
      redirect_to admin_conference_sponsorship_levels_path(conference_id: @conference.short_title),
                  alert: 'You need to create atleast one sponsorship level to add a sponsor'
    end
  end
end
