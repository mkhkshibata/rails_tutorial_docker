class AccountActivationsController < ApplicationController

	#有効化用リンクでアクセスした時、パスワードを介さずDBを更新する
	def edit
		user = User.find_by(email: params[:email])
		# if user && !user.activated? && user.authenticated?(:activation, params[:id])
		if user && !user.activated? && user.authenticated?(:activation, params[:id])
			user.activate
			log_in(user)
			flash[:success] = "アカウントが有効になりました"
			redirect_to user
		# else
		# 	flash[:danger] = "無効なリンクです"
		# 	redirect_to root_url
		end
	end
end
