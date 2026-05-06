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
end
