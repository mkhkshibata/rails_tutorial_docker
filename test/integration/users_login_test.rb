require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:micheal)
  end

  test "間違った情報でログインした場合、再度ログインページが表示され、フラッシュが出る" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: @user.email, password: "invalid" } }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "有効なアカウントでログインした後、ログアウトを行う" do
    post login_path, params: { session: { email: @user.email, password: 'password' } }
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
    #他ブラウザでログアウトを行う
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "自動ログインを有効にしてログインした場合" do
    log_in_as(@user, remember_me: '1')
    #assert_not cookies[:remember_token].blank?
    assert_equal cookies[:remember_token], assigns(:user).remember_token
  end

  test "自動ログインを無効にしてログインした場合" do
    log_in_as(@user, remember_me: '1')
    #forgetされているか確認
    log_in_as(@user, remember_me: '0')
    assert cookies[:remember_token].blank?
    assert_empty cookies[:remember_token]
  end
end
