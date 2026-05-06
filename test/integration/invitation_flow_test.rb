require "test_helper"

class InvitationFlowTest < ActionDispatch::IntegrationTest
  test "creator can invite a user by email" do
    sign_in users(:alice)
    event = events(:alice_picnic)

    assert_difference -> { Invitation.count } => 1 do
      post event_invitations_path(event), params: { email: users(:charlie).email }
    end
    assert_includes event.reload.invitees, users(:charlie)
  end

  test "non-creator cannot invite users" do
    sign_in users(:bob)
    event = events(:alice_picnic)

    assert_no_difference -> { Invitation.count } do
      post event_invitations_path(event), params: { email: users(:charlie).email }
    end
    assert_redirected_to event
  end

  test "inviting a non-existent email shows an alert and creates nothing" do
    sign_in users(:alice)
    event = events(:alice_picnic)

    assert_no_difference -> { Invitation.count } do
      post event_invitations_path(event), params: { email: "nobody@example.com" }
    end
    follow_redirect!
    assert_match(/no user/i, flash[:alert] || @response.body)
  end

  test "creator cannot invite themselves" do
    sign_in users(:alice)
    event = events(:alice_picnic)

    assert_no_difference -> { Invitation.count } do
      post event_invitations_path(event), params: { email: users(:alice).email }
    end
  end

  test "creator can remove an invitation" do
    sign_in users(:alice)
    invitation = invitations(:bob_invited_to_secret)

    assert_difference -> { Invitation.count } => -1 do
      delete event_invitation_path(invitation.event, invitation)
    end
  end

  test "after being invited, a user can register for a private event" do
    # Charlie isn't invited initially
    sign_in users(:charlie)
    event = events(:private_party)
    post event_registration_path(event)
    assert_redirected_to root_path  # blocked because show is gated

    # Alice invites charlie
    sign_in users(:alice)
    post event_invitations_path(event), params: { email: users(:charlie).email }
    assert_includes event.reload.invitees, users(:charlie)

    # Now charlie can register
    sign_in users(:charlie)
    assert_difference -> { Registration.count } => 1 do
      post event_registration_path(event)
    end
    assert_includes users(:charlie).reload.attended_events, event
  end
end
