require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  test "the same invitee cannot be invited twice to the same event" do
    duplicate = Invitation.new(event: events(:private_party), invitee: users(:bob))
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:invitee_id], "has already been taken"
  end

  test "user.invited_events comes through received_invitations" do
    assert_includes users(:bob).invited_events, events(:private_party)
    assert_empty users(:charlie).invited_events
  end
end
