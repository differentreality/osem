class SponsorEmail
  include ActiveModel::Model
  # extend ActiveModel::Translation
  attr_accessor :to, :from, :body, :subject

  validates :to, :from, presence: true
end
