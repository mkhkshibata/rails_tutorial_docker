class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :disp, resize_to_limit: [400, 400]
  end
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image, content_type: { in: %w[image/jpeg image/gif image/png], message: "が有効なファイル形式ではありません" },
                    size: { less_than: 1.megabytes, message: "を5MB以内にしてください" }
end
