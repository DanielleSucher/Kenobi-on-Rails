class UserMailer < ActionMailer::Base
  default :from => "dsucher@gmail.com"

	def ready_email(user)
		@user = user
		@url  = "http://kenobi.herokuapp.com/users/#{@user.id}"
		if user.email.nil?
			mail(:to => "dsucher@gmail.com", :subject => "Whoops, user #{@user.askme_id} didn't get their email!")
		else
			mail(:to => @user.email, :subject => "Kenobi is ready for you now!")
		end
	end
end
