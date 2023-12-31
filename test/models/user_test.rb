require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com", password: "foobarrr", password_digest: "foobarrr")
  end

  test "バリデーションの有効性テスト" do
    #バリデーションを通るとtrue返す
    assert @user.valid?
  end

  test "name属性は空白ではいけない" do
    @user.name = "     "
    #バリデーションに引っかかるとfalse返す
    assert_not @user.valid?
  end

  test "email属性は空白ではいけない" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "名前の文字数制限（50文字まで）" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "メールの文字数制限（255文字まで）" do
    @user.email = "a" * 244 + "example.com"
    assert_not @user.valid?
  end

  test "様々な有効なメールアドレスでテストする" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect}、バリデーションをかけてください"
    end
  end

  test "様々な無効なメールアドレスでテストする" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect}、無効なアドレスです。バリデーションをかけてください"
    end
  end

  test "メールアドレスが重複していないかのテスト" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "メールアドレスを小文字にして保存できているかのテスト" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "パスワードが空ではいけないテスト" do
    @user.password = @user.password_confirmation = " " * 8
    assert_not @user.valid?
  end

  test "パスワードが8文字以上であるテスト" do
    @user.password = @user.password_confirmation = "a" * 7
    assert_not @user.valid?
  end

  test "データベースにremember_digest属性がない場合、authenticated?がfalseを返す" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "関連づけられているマイクロポストの投稿が削除される" do
    @user.save
    @user.microposts.create!(content: "マイクロポスト削除テスト")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "ユーザーをフォローしフォロー解除を行うテスト" do
    micheal = users(:micheal)
    archer = users(:archer)
    assert_not micheal.following?(archer)
    micheal.follow(archer)
    assert micheal.following?(archer)
    assert archer.followers.include?(micheal)
    micheal.unfollow(archer)
    assert_not micheal.following?(archer)
    #自分自身をフォローできない
    micheal.follow(micheal)
    assert_not micheal.following?(micheal)
  end

  test "正しい投稿がフィードされているかのテスト" do
    micheal = users(:micheal)
    archer = users(:archer)
    lana = users(:lana)
    #フォローしているユーザー（lana）の投稿を確認
    lana.microposts.each do |post_following|
      assert micheal.feed.include?(post_following)
    end
    #フォロワーがいるユーザー自身（micheal）の投稿を確認
    micheal.microposts.each do |post_self|
      assert micheal.feed.include?(post_self)
      assert_equal micheal.feed.distinct, micheal.feed
    end
    #フォローしていないユーザー（archer）の投稿を確認
    archer.microposts.each do |post_unfollowed|
      assert_not micheal.feed.include?(post_unfollowed)
    end
  end
end
