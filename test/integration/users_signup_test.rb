require "test_helper"

#新規登録セットアップ、メール配信をクリアする
class UsersSignup < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
end

#新規登録テスト
class UsersSignup01Test < UsersSignup

  test "無効な新規登録" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: "", email: "user@invalid", password: "foo", password_confirmation: "bar"} }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.alert'
  end

  test "有効な新規登録とアカウント有効化" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Example User", email: "user@example.com", password: "password", password_confirmation: "password"} }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end

#アカウント有効化のテスト
class AccountActivationTest < UsersSignup

  def setup
    super
    post users_path, params: { user: { name: "Example User", email: "user@example.com", password: "password", password_confirmation: "password"} }
    @user = assigns(:user)
  end

  test "初期段階ではアカウントが有効化されていない" do
    assert_not @user.activated?
  end

  test "アカウントが有効化されていない場合、ログインすることができない" do
    log_in_as(@user)
    assert_not is_logged_in?
  end

  test "無効なアクティベーショントークンの場合、ログインできない" do
    get edit_account_activation_path("invalid token", email: @user.email)
    assert_not is_logged_in?
  end

  test "無効なアドレスの場合、ログインできない" do
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    assert_not is_logged_in?
  end

  test "有効なアクティベーショントークンとアドレスの場合、ログインできる" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end

end


############################################################


class UsersSignup02Test < ActionDispatch::IntegrationTest

  test "新規登録ページに無効なリクエストが送られた時のレスポンスとテンプレート、エラー表示がされるかのテスト" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: "", email: "user@invalid", password: "foo", password_confirmation: "bar"} }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.alert'
  end

  test "新規登録が成功したときのテスト（データベースに1件登録されているか、リダイレクトしたときのリダイレクト先のテンプレート、flash表示がされるか（=空ではない））" do
    assert_difference "User.count", 1 do
      post users_path, params:  { user: { name: "Example User", email: "user@example.com", password: "password", password_confirmation: "password"} }
    end
    follow_redirect!
    # assert_template "users/show"
    assert_not flash.empty?
    # assert is_logged_in?
  end
end
