require "test_helper"

#ユーザーの定義
class UsersIndex < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:micheal)
    @non_admin = users(:archer)
  end
end

#管理者ユーザーとしてログイン（ユーザー一覧ページへ）
class UsersIndexAdmin < UsersIndex

  def setup
    super
    log_in_as(@admin)
    get users_path
  end
end

#管理者ユーザーでテスト
class UsersIndexAdminTest < UsersIndexAdmin

  test "一覧ページのテンプレートのテスト" do
    assert_template 'users/index'
  end

  test "ページネーションが存在している" do
    assert_select 'div.pagination', count: 2
  end

  test "削除リンクが表示されている" do
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: "削除"
      end
    end
  end

  test "非管理者（管理者以外）を削除することができる" do
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
      assert_response :see_other
      assert_redirected_to users_url
    end
  end

  test "activatedがtrueになったユーザーのみ表示されている" do
    User.paginate(page: 1).first.toggle!(:activated)
    get users_path
    assigns(:users).each do |user|
      assert user.activated?
    end
  end
end

#管理権限のないユーザーでテスト
class UsersNonAdminIndexTest < UsersIndex

    test "非管理者は削除リンクが表示されない" do
      log_in_as(@non_admin)
      get users_path
      assert_select 'a', text: "削除", count: 0
    end
end


############################################################


class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:micheal)
    @non_admin = users(:archer)
  end

  test "管理者ユーザーがログイン後、ユーザー一覧ページをリクエストした時、ページネーションと削除リンクが表示される。削除リンクが問題なく動くことを検証" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: "削除"
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
      assert_response :see_other
      assert_redirected_to users_url
    end
  end

  test "ログインユーザーが管理者ユーザーでないとき、削除リンクが表示されない" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: "削除", count: 0
  end
end

