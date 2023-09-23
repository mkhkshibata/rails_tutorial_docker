module SessionsHelper

	#sessionメソッドを用いてブラウザに暗号化したユーザーID、session_tokenを作成し格納する
	def log_in(user)
		session[:user_id] = user.id
		session[:session_token] = user.session_token
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
			user = User.find_by(id: user_id)
			if user && session[:session_token] == user.session_token
				@current_user = user
			end
		#ブラウザにcookieが格納されていたら
		elsif (user_id = cookies.encrypted[:user_id])
			user = User.find_by(id: user_id)
			if user&.authenticated?(:remember, cookies[:remember_token])
				#セッションIDを与えてユーザーオブジェクトを格納する
				log_in user
				@current_user = user
			end
		end
	end

	#渡されたユーザーが現在ログイン中のユーザーか確認する
	def current_user?(user)
		user && user == current_user
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

	#ログイン前にGETリクエストしようとしたURLを保存する
	def store_location
		session[:forwarding_url] = request.original_url if request.get?
	end
end
