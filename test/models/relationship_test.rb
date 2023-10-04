require "test_helper"

class RelationshipTest < ActiveSupport::TestCase

  def setup
    @relationship = Relationship.new(follower_id: users(:micheal).id,
                                      followed_id: users(:archer).id)
  end

  test "有効である場合" do
    assert @relationship.valid?
  end

  test "フォローしているIDが必要" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  test "フォローされているIDが必要" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end
