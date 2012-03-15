require 'askmeanswerscraper'
require 'askmequestionscraper'
require 'naivebayes'

class User < ActiveRecord::Base
	attr_accessible :askme_id, :total_words, :total_docs, :should_words, :should_not_words, 
					:should_docs, :should_not_docs, :train, :train_word, :training_status


    has_many :words, :dependent => :destroy
    has_many :results, :dependent => :destroy

    validates_presence_of :askme_id

    def train
        self.update_attribute(:training_status, "started")
    	# prep the classifier
    	categories = ["should","should_not"]
        classifier = NaiveBayes.new(categories,self)
        # clear out old totals from the user, in case this is a retraining
        self.total_words = 0
        self.total_docs = 0
        self.should_words = 0
        self.should_not_words = 0
        self.should_docs = 0
        self.should_not_docs = 0
        self.save
    	# run the answer scraper
        scraper = AskMeAnswerScraper.new(self.askme_id)
        scraper.scrape_logged_in
        # train Kenobi on the results
        scraper.should_answer_training.each do |question|
            classifier.train("should", question)
        end
        scraper.should_not_answer_training.each do |question|
            classifier.train("should_not", question)
        end
        self.save
        self.reload
        self.update_attribute(:training_status, "done")
    end

    def train_word(category,word,count)
    	self.total_words += count
        self.save
        cat = category+"_words"
        self.update_attribute(cat.to_sym, self[cat.to_sym] + count)
    	save_word = self.words.find(:first, 
                    :conditions => { :wordstem => word }) || self.words.create!( :wordstem => word)
        save_word.update_attribute(category.to_sym,count)
    end

    def classify(pages)
    	# delete the last batch of results this user had
        self.results.destroy_all
    	# prep the classifier and the session variable
    	categories = ["should","should_not"]
        classifier = NaiveBayes.new(categories,self)
    	# run the question scraper
    	question_scraper = AskMeQuestionScraper.new
		question_scraper.scrape(pages) # specifies how many pages of questions should Kenobi scrape and analyze
		# classify the results
		question_scraper.new_questions.each do |question|
			self.results.create!( :url => "http://ask.metafilter.com#{question[:url]}", 
				:content => question[:content] ) if classifier.classify(question[:content]) == "should"
		end
    end
end
