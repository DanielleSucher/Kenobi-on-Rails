class UserMailer < ActionMailer::Base
  default :from => "dsucher@gmail.com"

	def ready_email(user)
		@user = user
		@url  = "http://kenobi.herokuapp.com"
		mail(:to => user.email, :subject => "Kenobi is ready for you now!")
	end
end
