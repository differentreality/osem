class Invoice < ApplicationRecord
  # has_paper_trail

  belongs_to :recipient, polymorphic: true
  belongs_to :conference
  serialize :description, Array

  has_and_belongs_to_many :ticket_purchases

  validates :no, :date, :payable, presence: true
  validates :no, numericality: { greater_than: 0 }, uniqueness: { scope: :conference_id }

  enum kind: {
    sponsorship: 0,
    ticket_purchase: 1
  }
end
