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
end
