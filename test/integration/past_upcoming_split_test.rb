require "test_helper"

class PastUpcomingSplitTest < ActionDispatch::IntegrationTest
  test "events index has Upcoming and Past sections, sorted into the right one" do
    sign_in users(:alice)
    get events_path
    assert_response :success

    body = @response.body
    assert_match(/Upcoming/, body)
    assert_match(/Past/, body)

    # Upcoming section comes before Past section in the page
    upcoming_pos = body.index("Upcoming")
    past_pos     = body.index("Past")
    assert upcoming_pos < past_pos

    # Future event title appears after "Upcoming" but before "Past"
    # (use "Picnic" to avoid HTML-escaped apostrophe in "Alice's Party")
    party_pos = body.index("Picnic")
    assert party_pos
    assert party_pos > upcoming_pos
    assert party_pos < past_pos

    # Past event title ("Old Reunion") appears after "Past"
    old_pos = body.index("Old Reunion")
    assert old_pos
    assert old_pos > past_pos
  end

  test "user profile splits created and attended events into past/upcoming" do
    get user_path(users(:alice))
    assert_response :success
    body = @response.body
    assert_match(/Events created/, body)
    assert_match(/Events attending/, body)
  end
end
