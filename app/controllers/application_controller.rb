class ApplicationController < ActionController::Base
	def hello
		render html: "Success!!!At Last!!!"
	end
end
