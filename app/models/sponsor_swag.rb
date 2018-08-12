# frozen_string_literal: true

class SponsorSwag < ApplicationRecord
  belongs_to :sponsor
  has_and_belongs_to_many :sponsor_shipments

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  validates :name, :quantity, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

  private

  def conference_id
    sponsor.conference_id
  end
end
