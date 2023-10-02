require "test_helper"

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:micheal)
    @micropost = @user.microposts.build(content: "Test用のテスト投稿です。")
  end

  test "マイクロポストが有効である" do
    assert @micropost.valid?
  end

  test "user_idが存在している。存在していない場合は無効である" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "マイクロポストの投稿内容が入っている。空ではない" do
    @micropost.content = "  "
    assert_not @micropost.valid?
  end

  test "マイクロポストの投稿内容の文字数が140文字以内である" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  test "最新の投稿が一番初めに存在している" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
