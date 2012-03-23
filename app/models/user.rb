require 'askmeanswerscraper'
require 'askmequestionscraper'
require 'naivebayes'

class User < ActiveRecord::Base
	attr_accessible :askme_id, :total_words, :total_docs, :should_words, :should_not_words, 
					:should_docs, :should_not_docs, :train, :train_word, :training_status, :email, :wordstems

    has_many :results, :dependent => :destroy

    validates_presence_of :askme_id

    def train
        self.update_attribute :training_status, "started"
    	# prep the classifier
    	categories = ["should","should_not"]
        classifier = NaiveBayes.new categories,self
        # clear out old totals from the user, in case this is a retraining
        self.total_words = 0
        self.total_docs = 0
        self.should_words = 0
        self.should_not_words = 0
        self.should_docs = 0
        self.should_not_docs = 0
        self.save
        self.reload
    	# run the answer scraper
        scraper = AskMeAnswerScraper.new self.askme_id
        scraper.scrape_logged_in
        # train Kenobi on the results
        scraper.should_answer_training.each do |question|
            classifier.train "should", question
        end
        scraper.should_not_answer_training.each do |question|
            classifier.train "should_not", question
        end
        classifier.compress_word_hash
        self.update_attribute :training_status, "done"
        UserMailer.ready_email(self).deliver unless self.email.nil?
    end

    def classify(pages)
    	# delete the last batch of results this user had
        self.results.destroy_all
        Rails.cache.fetch 'new_questions', :expires_in => 1.hour do
        	# run the question scraper
        	question_scraper = AskMeQuestionScraper.new
    		question_scraper.scrape(pages) # specifies how many pages of questions should Kenobi scrape and analyze
    		# classify the results
    		question_scraper.new_questions
        end
        new_questions = Rails.cache.read 'new_questions'
        # prep the classifier
        categories = ["should","should_not"]
        classifier = NaiveBayes.new categories,self
        classifier.decompress_word_hash
        new_questions.each do |question|
			self.results.create!( :url => "http://ask.metafilter.com#{question[:url]}", 
				:content => question[:content] ) if classifier.classify(question[:content]) == "should"
		end
    end
end
