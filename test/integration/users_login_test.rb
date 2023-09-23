require "test_helper"

#ユーザー定義
class UsersLogin < ActionDispatch::IntegrationTest

  def setup
    @user = users(:micheal)
  end
end

#有効なアドレスと無効なパスワードの場合のテスト
class InvalidPasswordTest < UsersLogin

  test "ログインページへ遷移する" do
    get login_path
    assert_template 'sessions/new'
  end

  test "有効なメールアドレスと無効なパスワードの場合のテスト" do
    post login_path, params: { session: { email: @user.email, password: "invalid" } }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end

#有効なログインの場合のセットアップ
class ValidLogin < UsersLogin

  def setup
    super
    post login_path, params: { session: { email: @user.email, password: "password" } }
  end
end

#有効なログインの場合のテスト
class ValidLoginTest < ValidLogin

  test "有効なログイン" do
    assert is_logged_in?
    assert_redirected_to @user
  end

  test "有効なログインをするとリダイレクトする" do
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end

end

#ログアウトする場合のセットアップ
class Logout < ValidLogin

  def setup
    super
    delete logout_path
  end
end

#ログアウトのテスト
class LogoutTest < Logout

  test "ログアウトが成功した場合、リダイレクトする" do
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "リダイレクトした後の表示" do
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "他ブラウザにおいてもログアウトされている（リダイレクトされる）" do
    delete logout_path
    assert_redirected_to root_url
  end
end

#アカウントを記憶するのテスト
class RememberingTest < UsersLogin

  test "自動ログインをチェックしてログインした場合、remember_tokenがcookieに格納されている" do
    log_in_as(@user, remember_me: '1')
    assert_not cookies[:remember_token].blank?
    #assert_equal cookies[:remember_token], assigns(:user).remember_token
  end

  test "自動ログインをチェックせずにログインした場合、remember_tokenがcookieが空である" do
    log_in_as(@user, remember_me: '1')
    #forgetされているか確認
    log_in_as(@user, remember_me: '0')
    assert cookies[:remember_token].blank?
    #assert_empty cookies[:remember_token]
  end
end


############################################################


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
