require "test_helper"

class Users::PushSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in :david
  end

  test "create new push subscription" do
    subscription_params = { "endpoint" => "https://apple", "p256dh_key" => "123", "auth_key" => "456" }

    post user_push_subscriptions_url,
      params: { push_subscription: subscription_params }, headers: { "HTTP_USER_AGENT" => "Mozilla/5.0" }

    assert_response :ok

    assert_equal subscription_params, users(:david).push_subscriptions.last.attributes.slice("endpoint", "p256dh_key", "auth_key")
    assert_equal "Mozilla/5.0", users(:david).push_subscriptions.last.user_agent
  end

  test "touch existing subscription" do
    assert_no_difference -> { users(:david).push_subscriptions.count } do
      assert_changes -> { push_subscriptions(:david_chrome).reload.updated_at } do
        post user_push_subscriptions_url(params: {
          push_subscription: push_subscriptions(:david_chrome).attributes.slice("endpoint", "p256dh_key", "auth_key")
        })
      end
    end

    assert_response :ok
  end

  test "destroy a push subscription via dev mode" do
    assert_difference -> { Push::Subscription.count }, -1 do
      delete user_push_subscription_url(push_subscriptions(:david_chrome))
      assert_redirected_to user_push_subscriptions_url
    end
  end
end
