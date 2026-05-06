require "test_helper"

class RegistrationTest < ActiveSupport::TestCase
  test "user cannot register twice for the same event" do
    duplicate = Registration.new(user: users(:bob), event: events(:alice_party))
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end
end
