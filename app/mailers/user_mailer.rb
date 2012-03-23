class UserMailer < ActionMailer::Base
  default :from => "YOUR_EMAIL_ADRESS"

	def ready_email(user)
		@user = user
		@url  = "URL"
		mail(:to => user.email, :subject => "Kenobi is ready for you now!")
	end
end
