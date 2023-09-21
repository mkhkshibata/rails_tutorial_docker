require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:micheal)
    @other_user = users(:archer)
  end

  test "ログインしていないときにユーザー変更ページへアクセスできず、flashが表示され、ログインページへリダイレクトされる" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "ログインしていないときにupdateアクションでユーザー情報が更新できず、flashが表示され、ログインページへリダイレクトされる" do
    patch user_path(@user), params: { user: {name: "@user.name", email: "@user.email"} }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "ログインしている違うユーザーが、ユーザー情報変更ページへアクセスしようとしたときリダイレクトする" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "ログインしている違うユーザーが、ユーザー情報を変更しようとしたときリダイレクトする" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: {name: "@user.name", email: "@user.email"} }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "ログインせずにユーザー一覧ページにアクセスするとログインページへリダイレクトされる" do
    get users_path
    assert_redirected_to login_url
  end

  test "ログインしていない時、ユーザー情報の変更はできない（リダイレクトされる）" do
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "管理者ユーザーでない場合、ユーザー情報の変更はできない" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@user), params: { user: { password: "password", password_confirmation: "password", admin: true } }
    assert_not @other_user.reload.admin?
  end

  test "ログインしていないとき、ユーザーの削除はできない（see_otherレスポンスが返され、リダイレクトされる）" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "ログインしているが管理者ユーザーでないとき、ユーザーの削除はできない（see_otherレスポンスが返され、リダイレクトされる）" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end
end
