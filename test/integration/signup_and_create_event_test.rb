require "test_helper"

class SignupAndCreateEventTest < ActionDispatch::IntegrationTest
  test "a new user can sign up and create an event with themselves as creator" do
    assert_difference -> { User.count } => 1 do
      post user_registration_path, params: {
        user: {
          name: "Carol",
          email: "carol@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    carol = User.find_by!(email: "carol@example.com")
    assert_equal "Carol", carol.name

    assert_difference -> { Event.count } => 1 do
      post events_path, params: {
        event: {
          title: "Carol's Picnic",
          description: "BYO blanket.",
          starts_at: 1.week.from_now.to_s,
          location: "The park"
        }
      }
    end

    event = Event.last
    assert_equal "Carol's Picnic", event.title
    assert_equal carol, event.creator
    assert_includes carol.created_events, event
  end
end
