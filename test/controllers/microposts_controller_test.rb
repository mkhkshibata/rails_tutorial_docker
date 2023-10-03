require "test_helper"

class MicropostsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @micropost = microposts(:orange)
  end

  test "ログインをしないでマイクロポストの作成はできない。リダイレクトされる" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "test投稿" } }
    end
    assert_redirected_to login_url
  end

  test "ログインしないでマイクロポストの削除はできない。リダイレクトされる" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "本人ではないユーザーの投稿を削除したときはリダイレクトされる" do
    log_in_as(users(:micheal))
    micropost = microposts(:ants)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(micropost)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end
end
