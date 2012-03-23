class PagesController < ApplicationController

	def home
		@user = User.new
	end

	def results
		@user = User.find_by_id(session[:user_id])
	end

	def about
	end
end
