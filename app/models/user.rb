class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true

  has_many :created_events,
           class_name: "Event",
           foreign_key: "creator_id",
           inverse_of: :creator,
           dependent: :destroy

  has_many :registrations, dependent: :destroy
  has_many :attended_events, through: :registrations, source: :event

  has_many :received_invitations,
           class_name: "Invitation",
           foreign_key: "invitee_id",
           inverse_of: :invitee,
           dependent: :destroy
  has_many :invited_events, through: :received_invitations, source: :event
end
