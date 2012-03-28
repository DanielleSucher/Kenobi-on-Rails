require 'askmeanswerscraper'
require 'feedzirra'
require 'naivebayes'

class User < ActiveRecord::Base
	attr_accessible :askme_id, :name, :total_words, :total_docs, :should_words, :should_not_words, 
					:should_docs, :should_not_docs, :train, :train_word, :training_status, :email, :wordstems

    has_many :results, :dependent => :destroy

    validates_presence_of :name

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
        scraper = AskMeAnswerScraper.new self
        scraper.get_askme_id
        if self.askme_id == "kenobi" # denotes name not found
            self.update_attribute :training_status, "name_not_found"
            UserMailer.fail_email(self).deliver
        else
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
            UserMailer.ready_email(self).deliver
        end
    end

    def classify
    	# delete the last batch of results this user had
        self.results.destroy_all
        # fetch new questions from the AskMeFi RSS feed
        feed = Feedzirra::Feed.fetch_and_parse "http://feeds.feedburner.com/AskMetafilter"
        new_questions= []
        feed.entries.each do |entry|
            url = entry.url
            content = entry.summary.gsub(/\<(br|div)\b[\w\W]+/,"")
            new_questions << { :content => content, :url => url }
        end
        # prep the classifier
        categories = ["should","should_not"]
        classifier = NaiveBayes.new categories,self
        classifier.decompress_word_hash
        # classify each new question
        new_questions.each do |question|
            # question[:score] = classifier.classify question[:content]
            # puts question
            if classifier.classify(question[:content]) == "should"
                self.results.create!(:url => question[:url], :content => question[:content])
            end
        end
    end
end
