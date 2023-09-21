require "test_helper"

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
    first_page_of_users = User.paginate(page: 1)
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

