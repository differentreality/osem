class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :conference

  has_and_belongs_to_many :payments

  validates :no, :date, :payable, presence: true
  validates :no, numericality: { greater_than: 0 }
end
