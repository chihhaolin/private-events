require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "is invalid without title or starts_at" do
    event = Event.new(creator: users(:alice))
    assert_not event.valid?
    assert_includes event.errors[:title],     "can't be blank"
    assert_includes event.errors[:starts_at], "can't be blank"
  end

  test "creator returns the User who created it" do
    assert_equal users(:alice), events(:alice_party).creator
  end

  test "attendees lists registered users" do
    assert_includes events(:alice_party).attendees, users(:bob)
    assert_empty events(:alice_picnic).attendees
  end

  test "Event.upcoming returns events with starts_at in the future" do
    assert_includes Event.upcoming, events(:alice_party)
    assert_includes Event.upcoming, events(:alice_picnic)
    assert_not_includes Event.upcoming, events(:past_event)
  end

  test "Event.past returns events with starts_at in the past" do
    assert_includes Event.past, events(:past_event)
    assert_not_includes Event.past, events(:alice_party)
  end

  test "public event is visible to anyone, including unauthenticated users" do
    assert events(:alice_party).visible_to?(nil)
    assert events(:alice_party).visible_to?(users(:charlie))
  end

  test "private event is visible to creator, invitees, and attendees only" do
    secret = events(:private_party)
    assert secret.visible_to?(users(:alice)),   "creator should see it"
    assert secret.visible_to?(users(:bob)),     "invitee should see it"
    assert_not secret.visible_to?(users(:charlie)), "stranger should not see it"
    assert_not secret.visible_to?(nil),             "guest should not see it"
  end

  test "invitees lists invited users" do
    assert_includes events(:private_party).invitees, users(:bob)
    assert_not_includes events(:private_party).invitees, users(:charlie)
  end
end
