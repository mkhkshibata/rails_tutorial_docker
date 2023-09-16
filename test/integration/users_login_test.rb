require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  test "間違った情報でログインした場合、再度ログインページが表示され、フラッシュが出る" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_response :unprocessable_entity
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end
