require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com")
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

  test "様々なメールアドレスでテストする" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
end
