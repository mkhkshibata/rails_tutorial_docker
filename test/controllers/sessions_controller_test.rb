require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "ログインにリクエスト" do
    get login_url
    assert_response :success
  end
end
