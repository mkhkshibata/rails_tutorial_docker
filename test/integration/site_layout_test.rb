require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "ページにリクエストをした際の、テンプレートとリンクのテスト" do
    # rootページ
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    # contactページ
    get contact_path
    assert_select "title", full_title("Contact")
    # signupページ
    get signup_path
    assert_select "title", full_title("Sign up")

  end
end
