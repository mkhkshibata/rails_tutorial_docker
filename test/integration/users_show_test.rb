require "test_helper"

class UsersShowTest < ActionDispatch::IntegrationTest

  def setup
    @inactive_user = users(:inactive)
    @active_user = users(:archer)
  end

  test "activatedがfalseの時、マイページは表示されずリダイレクトされる" do
    get user_path(@inactive_user)
    assert_response :redirect
    assert_redirected_to root_url
  end

  test "activatedがtrueになったら、マイページが表示される" do
    get user_path(@active_user)
    assert_response :success
    assert_template 'users/show'
  end
end
