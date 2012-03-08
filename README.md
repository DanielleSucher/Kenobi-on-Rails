A naive Bayesian classifier and pair of scrapers to determine which Ask Metafilter questions a user should answer,
after being trained on that user's profile to see questions where their past answers have received favorites as good, and questions where their past answers received no favorites as bad. (The threshold can be set anywhere you like, over in app/helpers/askmeanswerscraper.rb).

Remember, the more questions a user has answered before, the more accurate this will be!

This is the single best explanation of Bayes' Theorem I know of, incidentally - http://yudkowsky.net/rational/bayes

And if you're interested in the history of Bayes' Theorem - http://lesswrong.com/lw/774/a_history_of_bayes_theorem/

Ruby 1.9.3, Rails 3.2, see Gemfile for dependencies.

To use, you'll need to go into app/helpers/askmeanswerscraper.rb and on lines95-95, change "METAFILTER_USER_NAME" and "METAFILTER_USER_PASSWORD" to the username and password for any Metafiler account, so that Mechanize will be able to log in and see favorite counts when scraping users' profile pages for data on their past answers to old questions and training the classifier. (I temporarily changed my password for testing, and ultimately just paid my $5 to create an extra account for the live version of Kenobi that's currently up at http://kenobi.heroku.com.)