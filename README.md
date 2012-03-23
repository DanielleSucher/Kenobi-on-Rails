A naive Bayesian classifier and pair of scrapers to determine which Ask Metafilter questions a user should answer,
after being trained on that user's profile to see questions where their past answers have received favorites as good, and questions where their past answers received no favorites as bad. (The threshold can be set anywhere you like, over in app/helpers/askmeanswerscraper.rb).

Remember, the more questions a user has answered before, the more accurate this will be!

This is the single best explanation of Bayes' Theorem I know of, incidentally - http://yudkowsky.net/rational/bayes

And if you're interested in the history of Bayes' Theorem - http://lesswrong.com/lw/774/a_history_of_bayes_theorem/

***

To get this working, you'll first have to edit lines 94-95 in app/helpers/askmeanswerscraper.rb to change "METAFILTER_USER_NAME" and "METAFILTER_USER_PASSWORD" to some actual metafilter username/password combo so that Mechanize will be able to log in and scrape user profile answers favcnt data. Also, change the email address and URL in the mailer, and set the environment variables for Dalli and thet mailer SMTP settings.

Ruby 1.9.3, Rails 3.2, see Gemfile for dependencies. Don't forget to bundle install and rake db:migrate!