require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "is invalid without a name" do
    user = User.new(email: "noname@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "created_events returns events where this user is the creator" do
    assert_includes users(:alice).created_events, events(:alice_party)
    assert_includes users(:alice).created_events, events(:alice_picnic)
    assert_empty users(:bob).created_events
  end

  test "attended_events comes through registrations" do
    assert_includes users(:bob).attended_events, events(:alice_party)
    assert_not_includes users(:bob).attended_events, events(:alice_picnic)
    assert_empty users(:alice).attended_events
  end
end
