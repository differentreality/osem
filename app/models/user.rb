class User < ActiveRecord::Base
  include Gravtastic
  gravtastic :size => 32


  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  has_and_belongs_to_many :roles

  attr_accessible :email, :password, :password_confirmation, :remember_me, :role_id, :role_ids,
                  :name, :email_public, :biography, :nickname, :affiliation

  has_many :event_users, :dependent => :destroy
  has_many :events, -> { uniq }, :through => :event_users
  has_many :registrations, :dependent => :destroy
  has_many :votes, :dependent => :destroy
  has_many :voted_events, :through => :votes, :source => :events

  accepts_nested_attributes_for :roles

  before_create :setup_role

  validates :name, presence: true

  def role?(role)
    Rails.logger.debug("Checking role in user")
    !!roles.find_by_name(role.to_s.downcase.camelize)
  end

  def get_roles
    return self.roles
  end

  def setup_role
    roles << Role.find_by(name: 'Admin') if User.count == 0
    roles << Role.find_by(name: 'Participant') if roles.empty?
  end

  def self.prepare(params)
    email = params['email']
    user = User.where(email: email).first_or_initialize

    # If there is a new user, add the necessary attributes
    if user.new_record?
      user.password = Devise.friendly_token[0, 20]
      user.skip_confirmation!
      user.attributes = params
    end
    user
  end

  def registered
    registrations = self.registrations
    if registrations.count == 0
      'None'
    else
      registrations.map { |r| r.conference.title }.join ', '
    end
  end

  def attended
    registrations_attended = self.registrations.where(attended: true)
    if registrations_attended.count == 0
      'None'
    else
      registrations_attended.map { |r| r.conference.title }.join ', '
    end
  end

  def confirmed?
    !confirmed_at.nil?
  end

  def attending_conference? conference
    Registration.where(:conference_id => conference.id,
                       :user_id => self.id).count
  end

  def proposals conference
    events.where('conference_id = ? AND event_users.event_role=?', conference.id, 'submitter')
  end

  def proposal_count conference
    proposals(conference).count
  end

  def biography_word_count
    if self.biography.nil?
      0
    else
      self.biography.split.size
    end
  end
  private
    def biography_limit
      if !self.biography.nil? && self.biography.split.size > 150
        errors.add(:abstract, "cannot have more than 150 words")
      end
    end
end
