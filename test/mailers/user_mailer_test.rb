require "test_helper"

class UserMailerTest < ActionMailer::TestCase

  test "アカウント有効化メールのテスト" do
    user = users(:micheal)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "アカウントを有効化して下さい", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["user@domain.com"], mail.from
    assert_match user.name, mail.html_part.body.to_s
    assert_match user.name, mail.text_part.body.to_s
    assert_match user.activation_token, mail.html_part.body.to_s
    assert_match user.activation_token, mail.text_part.body.to_s
    assert_match CGI.escape(user.email), mail.html_part.body.to_s
    assert_match CGI.escape(user.email), mail.text_part.body.to_s
  end

  test "パスワードリセットメールのテスト" do
    user = users(:micheal)
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)
    assert_equal "パスワードをリセットしてください", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["user@domain.com"], mail.from
    assert_match user.name, mail.html_part.body.to_s
    assert_match user.name, mail.text_part.body.to_s
    assert_match user.reset_token, mail.html_part.body.to_s
    assert_match user.reset_token, mail.text_part.body.to_s
    assert_match CGI.escape(user.email), mail.html_part.body.to_s
    assert_match CGI.escape(user.email), mail.text_part.body.to_s
  end

end
