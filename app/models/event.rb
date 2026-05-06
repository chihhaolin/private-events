class Event < ApplicationRecord
  belongs_to :creator, class_name: "User", inverse_of: :created_events

  has_many :registrations, dependent: :destroy
  has_many :attendees, through: :registrations, source: :user

  validates :title, :starts_at, presence: true
end
