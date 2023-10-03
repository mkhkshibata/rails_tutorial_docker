require "test_helper"

#セットアップ
class MicropostsInterface < ActionDispatch::IntegrationTest

  def setup
    @user = users(:micheal)
    log_in_as(@user)
  end
end

class MicropostsInterfaceTest < MicropostsInterface

  test "マイクロポスト用ページネーションが存在する" do
    get root_path
    assert_select 'div.pagination'
  end

  test "無効なマイクロポスト投稿ではエラーが出る" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'
  end

  test "有効なマイクロポスト投稿の場合" do
    content = "有効なマイクロポスト投稿"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end

  test "ユーザー本人のページでは投稿の削除リンクが表示されている" do
    get user_path(@user)
    assert_select 'a', text: "削除"
  end

  test "自分のマイクロポスト投稿は削除可能である" do
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
  end

  test "本人以外のユーザーページは投稿の削除リンクが表示されない" do
    get user_path(users(:archer))
    assert_select 'a', { text: "削除", count: 0 }
  end
end

class MicropostsSidebarTest < MicropostsInterface

  test "正しい投稿数が表示されている1" do
    get root_path
    assert_match @user.microposts.count.to_s, response.body
  end

  test "正しい投稿数が表示されている2" do
    log_in_as(users(:malory))
    get root_path
    assert_match users(:malory).microposts.count.to_s, response.body
  end

  test "正しい投稿数が表示されている3" do
    log_in_as(users(:lana))
    get root_path
    assert_match users(:lana).microposts.count.to_s, response.body
  end
end


class ImageUpTest < MicropostsInterface

  test "イメージアップ用のフォームが存在する" do
    get root_path
    assert_select 'input[type=file]'
  end

  test "postする際、イメージをアタッチすることができる" do
    cont = "この部屋は小さい"
    img = fixture_file_upload('kitten.jpg', 'image/jpeg')
    post microposts_path, params: { micropost: { content: cont, image: img } }
    assert assigns(:micropost).image.attached?
  end
end