require "test_helper"

class RegisterForEventTest < ActionDispatch::IntegrationTest
  test "a logged-in user can register and cancel registration for an event" do
    sign_in users(:alice)
    event = events(:alice_picnic)

    assert_not_includes users(:alice).attended_events, event

    assert_difference -> { Registration.count } => 1 do
      post event_registration_path(event)
    end
    assert_includes users(:alice).reload.attended_events, event

    assert_difference -> { Registration.count } => -1 do
      delete event_registration_path(event)
    end
    assert_not_includes users(:alice).reload.attended_events, event
  end

  test "registering twice is idempotent" do
    sign_in users(:bob)
    event = events(:alice_party)

    assert_no_difference -> { Registration.count } do
      post event_registration_path(event)
    end
    assert_includes users(:bob).reload.attended_events, event
  end
end
