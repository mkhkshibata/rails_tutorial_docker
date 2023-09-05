require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @base_title = 'Ruby on Rails Tutorial Sample App V3'
  end

  test "rootページのGETリクエストとタイトル表示のテスト" do
    get root_url
    assert_response :success
    assert_select "title", "#{@base_title}"
  end

  test "homeページのGETリクエストとタイトル表示のテスト" do
    get static_pages_home_url
    assert_response :success
    assert_select "title", "#{@base_title}"
  end

  test "helpページのGETリクエストとタイトル表示のテスト" do
    get static_pages_help_url
    assert_response :success
    assert_select "title", "Help | #{@base_title}"
  end

  test "aboutページのGETリクエストとタイトル表示のテスト" do
    get static_pages_about_url
    assert_response :success
    assert_select "title", "About | #{@base_title}"
  end

  test "contactページのGETリクエストとタイトル表示のテスト" do
    get static_pages_contact_url
    assert_response :success
    assert_select "title", "Contact | #{@base_title}"
  end
end
