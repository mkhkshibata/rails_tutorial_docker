require "test_helper"

class SessionsHelperTest < ActionView::TestCase

	def setup
		@user = users(:micheal)
		#トークンを生成して、暗号化を行いパスワードなしでデータベースに保存する
		remember(@user)
	end

	test "sessionが無い時、current_userとuserオブジェクトが同じ" do
		assert_equal @user, current_user
		assert is_logged_in?
	end

	test "remember digestが間違っている時、current_userがnilである" do
		@user.update_attribute(:remember_digest, User.digest(User.new_token))
		assert_nil current_user
	end
end