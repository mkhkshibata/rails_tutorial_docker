module SessionsHelper

	#sessionメソッドを用いてブラウザに暗号化したユーザーIDを持たせる
	def log_in(user)
		session[:user_id] = user.id
	end

	def remember(user)
		#トークンを作成し、remember_digest属性に保存
		user.remember
		#cookieに暗号化してユーザーIDを保存
		cookies.permanent.encrypted[:user_id] = user.id
		#user.rememberで作成して保持しているトークンをcookieにも格納する
		cookies.permanent[:remember_token] = user.remember_token
	end

	#current_userにブラウザのsessionから取得したユーザーオブジェクトを格納する
	def current_user
		#sessionを保持していたら格納しているユーザーIDから取得
		if (user_id = session[:user_id])
			@current_user ||= User.find_by(id: user_id)
		#ブラウザにcookieが格納されていたら
		elsif (user_id = cookies.encrypted[:user_id])
			user = User.find_by(id: user_id)
			if user&.authenticated?(cookies[:remember_token])
				#セッションIDを与えてユーザーオブジェクトを格納する
				log_in user
				@current_user = user
			end
		end
	end

	#ログイン中ならtrueを返す
	def logged_in?
		!current_user.nil?
	end

	#cookieを削除する
	def forget(user)
		user.forget
		cookies.delete(:user_id)
		cookies.delete(:remember_token)
	end

	def log_out
		#current_userメソッドで@current_userを返す
		forget(current_user)
		reset_session
		@current_user = nil
	end

end
