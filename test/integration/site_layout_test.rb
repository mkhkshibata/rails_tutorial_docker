require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest

  def setup 
    @user = users(:micheal)
  end


  test "ログインしていない場合、ページにリクエストをした際の、テンプレートとリンクのテスト" do
    # rootページ
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    assert_select "a[href=?]", login_path
    # contactページ
    get contact_path
    assert_select "title", full_title("Contact")
    # signupページ
    get signup_path
    assert_select "title", full_title("Sign up")
  end

  test "ページにリクエストをした際の、テンプレートとリンクのテスト" do
    # rootページ
    log_in_as(@user)
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "strong#following"
    assert_match @user.following.count.to_s, response.body
    assert_select "strong#followers"
    assert_match @user.followers.count.to_s, response.body
  end
end
