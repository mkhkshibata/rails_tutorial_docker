class User < ApplicationRecord
	#モデルの関連付け
	has_many :microposts, dependent: :destroy

	#仮想の属性を作成
	attr_accessor :remember_token, :activation_token, :reset_token

	# before_save { self.email = email.downcase }
	# before_save { email.downcase! }
	before_save :downcase_email
	# ユーザーが新規登録した際に処理される
	before_create :create_activation_digest
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
	has_secure_password
	validates :password, presence: true, length: { minimum: 8 }, allow_nil: true

	#暗号化するメソッド
	def self.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	#ランダムな文字列を返す
	def self.new_token
		SecureRandom.urlsafe_base64
	end

	#トークンを生成して、暗号化を行いパスワードなしでデータベースに保存する
	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
		#remember_digestを返す（暗号化済み）
		remember_digest
	end

	#remember_digestをsession_tokenとして再利用
	def session_token
		remember_digest || remember
	end

	#暗号化して保存しているremember_digest属性の値とcookiesのトークンの値を比較
	# def authenticated?(remember_token)
	# 	return false if remember_digest.nil?
	# 	BCrypt::Password.new(remember_digest).is_password?(remember_token)
	# end

	#暗号化して保存した属性と元になったトークンを比較するメソッドを汎用化
	def authenticated?(attribute, token)
		#メソッドが格納される
		digest = self.send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end

	#ログイン情報破棄
	def forget
		update_attribute(:remember_digest, nil)
	end

	#activated属性を更新する
	def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
		# update_columns(activated: true, activated_at: Time.zone.now)
  end

	#アカウント新規作成用のactivatedメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

	def create_reset_digest
		self.reset_token = User.new_token
		update_attribute(:reset_digest, User.digest(reset_token))
		update_attribute(:reset_sent_at, Time.zone.now)
		# update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
	end

	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end

	#2時間以上前だったらtrue
	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end
	private

		def downcase_email
			self.email = email.downcase
		end

		# メールリンク有効化トークン、ダイジェストを作成
		def create_activation_digest
			self.activation_token = User.new_token
			self.activation_digest = User.digest(activation_token)
		end
end
