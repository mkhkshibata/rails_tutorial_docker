require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  #full_titleヘルパーを利用可能にする
  include ApplicationHelper

  def setup
    @user = users(:micheal)
  end

  test "ユーザー設定ページの表示" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_select "strong#following"
    assert_match @user.following.count.to_s, response.body
    assert_select "strong#followers"
    assert_match @user.followers.count.to_s, response.body
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination', count: 1
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end

end
