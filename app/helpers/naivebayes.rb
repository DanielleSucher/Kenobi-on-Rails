# Created mostly while following the tutorial at http://blog.saush.com/2009/02/11/naive-bayesian-classifiers-and-ruby/

class NaiveBayes
    attr_accessor :words

    # Initialize with a list of the categories for this clasifier
    def initialize(categories,user)
        @user = user
        @categories = categories
        @threshold = 3.5 # how much more likely x has to be than y to bother declaring it
    end

    # Train the classifier!
    def train(category,document)
        word_count(document).each do |word,count|
            # if Word.where(:user_id => @user.id, :wordstem => word).first
            #     old_word = Word.where(:user_id => @user.id, :wordstem => word).first
            #     old_word[category.to_sym] = count
            # else
            #     @user.words.build( :wordstem => word, category.to_sym => count )
            # end
            @user.train_word(category,word,count)
        end
        cat = category+"_docs"
        User.increment_counter(cat.to_sym, @user.id)
        @user.total_docs += 1
        @user.save
    end

    # find the probability for each category and return a hash, category => probability thereof
    def probabilities(document)
        odds = Hash.new
        @categories.each do |category|
            odds[category] = self.probability(category,document)
            odds[category] = 0 if odds[category].nan?
        end
        return odds
    end

    # Classify any given document into one of the categories
    def classify(document)
        sorted = self.probabilities(document).sort_by { |a,b| b } # sorts into an array of arrays, asc by value
        best = sorted.pop
        second_best = sorted.pop
        best[1]/second_best[1] > @threshold || second_best[1] == 0 ? best[0] : "Unknown"
    end

    def relative_odds(document) #  a complete set of relative odds rather than a single absolute odd
        probs = self.probabilities(document).sort_by { |a,b| b } # sorts into an array of arrays, asc by value
        totals = 0
        relative = {}
        probs.each { |prob| totals += prob[1]}
        probs.each { |prob| relative[prob[0]] = "#{prob[1]/totals * 100}%" }
        return relative
    end

    def word_count(document)
        words = document.gsub(/[^\w\s]/,"").split 
        word_hash = Hash.new
        words.each do |word|
            word.downcase!
            key = word.stem
            unless COMMON_WORDS.include?(word) # Remove common words
                word_hash[key] ||= 0
                word_hash[key] += 1 # Each word is a key, and maps to the count of how often it appears
            end
        end
        return word_hash
    end

    def word_probability(category,word)
        # Basically the probability of a word in a category is the number of times it occurred 
        # in that category, divided by the number of words in that category altogether. 
        # Except we pretend every occured at least once per category, to avoid errors when encountering
        # words never encountered during training. (In latest draft, 0.1 instead of 1)
        # First draft: (times the word occurs in this category + 1)/total number of words in this category
        # Dave's draft: this_category = (@words[category][word].to_f + 1)/(@total_occurrences[word].to_f + 1)
        # @words[category].has_key?(word) ? test_word = @words[category][word].to_f : test_word = 0.1
        test_word = 0.0000000000000001
        test_word = @user.words.find(:first, :conditions => { :wordstem => word })[category.to_sym].to_f if
            @user.words.find(:first, :conditions => { :wordstem => word }) &&
            @user.words.find(:first, :conditions => { :wordstem => word })[category.to_sym] != 0
        cat = category+"_words"
        return test_word/@user[cat.to_sym].to_f
    end

    def document_probability(category,document)
        doc_prob = 1 # The document exists we're looking at exists, yep.
        word_count(document).each do |word|
            doc_prob *= self.word_probability(category,word[0]) # gets the word stem, not its count
        end
        # This calculates the probability of the document given the category, by multiplying
        # the probability of the document (100%, baby!) by the probability of each word 
        # in the document, given the category and how many times it appears
        return doc_prob
    end

    def category_probability(category)
        # This is just the probability that any random document might be in this category.
        cat = category+"_docs"
        return @user[cat.to_sym].to_f/@user.total_docs.to_f
    end

    def probability(category,document)
        return self.document_probability(category,document) * self.category_probability(category)
        # Pr(category|document) = (Pr(document|category) * Pr(category))/Pr(document)
        # The probability of category given the document = 
        # the probability of the document given the category * the probability of the category
        # (Divided by the probability of the documents, which I think we're assuming is always 1)
    end

    # SIGNIFICANTLY trimmed down
    COMMON_WORDS = ['a','an','and','the','them','he','him','her','she','their','we',
        'to','be','some','on','or','by','i','this','that','for','in','into','what']
end