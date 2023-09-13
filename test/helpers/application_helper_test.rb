require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
	test "full_titleメソッドヘルパーのテスト" do
		assert_equal "Ruby on Rails Tutorial Sample App V3", full_title
		assert_equal "Help | Ruby on Rails Tutorial Sample App V3", full_title("Help")
	end

end