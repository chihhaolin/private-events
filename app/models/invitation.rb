class Invitation < ApplicationRecord
  belongs_to :event
  belongs_to :invitee, class_name: "User", inverse_of: :received_invitations

  validates :invitee_id, uniqueness: { scope: :event_id }
end
