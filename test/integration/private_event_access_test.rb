require "test_helper"

class PrivateEventAccessTest < ActionDispatch::IntegrationTest
  test "non-invited user is redirected away from a private event show page" do
    sign_in users(:charlie)
    get event_path(events(:private_party))
    assert_redirected_to root_path
    follow_redirect!
    assert_match(/private/i, flash[:alert] || @response.body)
  end

  test "invitee can see the private event" do
    sign_in users(:bob)
    get event_path(events(:private_party))
    assert_response :success
    assert_match "Secret", @response.body  # event title contains "Secret"
  end

  test "creator can see the private event and the invitation manager" do
    sign_in users(:alice)
    get event_path(events(:private_party))
    assert_response :success
    assert_match "Manage invitations", @response.body
  end

  test "events index hides private events from non-related users" do
    sign_in users(:charlie)
    get events_path
    assert_response :success
    assert_no_match "Secret", @response.body
  end

  test "events index shows private events to invitees" do
    sign_in users(:bob)
    get events_path
    assert_response :success
    assert_match "Secret", @response.body
  end
end
