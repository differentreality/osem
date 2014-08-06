class Track < ActiveRecord::Base
  attr_accessible :name, :description, :color, :conference_id

  belongs_to :conference

  before_create :generate_guid

  private

  def generate_guid
    guid = SecureRandom.urlsafe_base64
#     begin
#       guid = SecureRandom.urlsafe_base64
#     end while Person.where(:guid => guid).exists?
    self.guid = guid
  end
end
