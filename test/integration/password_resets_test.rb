require "test_helper"

#テスト用セットアップ
class PasswordResets < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
end

#パスワード再設定フォーム（メール送信用）テスト
class ForgotPasswordFormTest < PasswordResets

  test "パスワードリセットへリクエスト" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
  end

  test "パスワードリセットフォームで無効なメールアドレスを送信する" do
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end
end

#パスワード再設定フォーム用セットアップ
class PasswordResetForm < PasswordResets

  def setup
    super
    @user = users(:micheal)
    post password_resets_path, params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
  end
end


#パスワード再設定フォーム（確認メール）のテスト
class PasswordFormTest < PasswordResetForm

  test "有効なメールアドレスの場合、メール送信される" do
    assert_not_equal @user.reset_digest, @reset_user.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "無効なメールアドレスで作成された変更フォームへのリンクにリクエストした場合、リダイレクトされる" do
    get edit_password_reset_path(@reset_user.reset_token, email: "")
    assert_redirected_to root_url
  end

  test "アクティベートされていないユーザーの場合の変更フォームへのリンク" do
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token, email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "有効なメールアドレスと無効なトークンの場合の変更フォームへのリンク" do
    get edit_password_reset_path('wrong token', email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "有効なメールアドレスと有効なトークンで変更フォームをリクエストした場合" do
    get edit_password_reset_path(@reset_user.reset_token, email: @reset_user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[name="email"][type="hidden"][value=?]', @reset_user.email
  end
end

#パスワード変更テスト
class PasswordFormTest < PasswordResetForm

  test "無効なパスワードとパスワード確認の場合" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password: "foobaz", password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
  end

  test "空のパスワードで更新した場合" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password: "", password_confirmation: "" } }
    assert_select 'div#error_explanation'
  end

  test "有効なパスワードとパスワード確認の場合" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
            user: { password: "foobarbaz", password_confirmation: "foobarbaz" } }
    assert is_logged_in?
    assert_nil @reset_user.reload.reset_digest
    assert_not flash.empty?
    assert_redirected_to @reset_user
  end
end

#有効期限切れテスト用セットアップ
class ExpiredToken < PasswordResets

  #トークンを失効させてセットアップ
  def setup
    super
    @user = users(:micheal)
    post password_resets_path, params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password: "foobarbaz", password_confirmation: "foobarbaz" } }
  end
end

class ExpiredTokenTest < ExpiredToken

  test "リンクの有効期限が切れていたらリダイレクトされる" do
    assert_redirected_to new_password_reset_url
  end

  test "有効期限切れの文言が入っている" do
    follow_redirect!
    assert_match '有効期限が切れています。', response.body
  end
end
