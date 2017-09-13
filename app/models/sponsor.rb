# frozen_string_literal: true

class Sponsor < ApplicationRecord
  include ActiveRecord::Transitions
  belongs_to :sponsorship_level
  belongs_to :conference

  serialize :swag, Array
  serialize :shipments, Array
  # serialize :swag, HashWithIndifferentAccess

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  mount_uploader :picture, PictureUploader, mount_on: :logo_file_name

  validates :name, :website_url, presence: true

  scope :confirmed, -> { where(state: 'confirmed') }
  scope :unconfirmed, -> { where(state: 'unconfirmed') }
  scope :with_swag, -> { where(has_swag: 1) }
  scope :with_shipment, -> { where.not(shipments: nil) }

  state_machine initial: :unconfirmed do
   state :unconfirmed
   state :confirmed

   event :confirm do
     transitions to: :confirmed, from: [:unconfirmed]
   end

   event :cancel do
     transitions to: :unconfirmed, from: [:confirmed]
   end
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(current_state).include?(transition)
  end
end
