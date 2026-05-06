class Event < ApplicationRecord
  belongs_to :creator, class_name: "User", inverse_of: :created_events

  has_many :registrations, dependent: :destroy
  has_many :attendees, through: :registrations, source: :user

  has_many :invitations, dependent: :destroy
  has_many :invitees, through: :invitations

  validates :title, :starts_at, presence: true

  scope :past,     -> { where("starts_at < ?", Time.current) }
  scope :upcoming, -> { where("starts_at >= ?", Time.current) }

  def visible_to?(user)
    return true unless private?
    return false unless user
    creator_id == user.id || invitees.exists?(user.id) || attendees.exists?(user.id)
  end
end
