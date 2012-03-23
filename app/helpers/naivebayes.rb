# Created mostly while following the tutorial at http://blog.saush.com/2009/02/11/naive-bayesian-classifiers-and-ruby/

class NaiveBayes
    attr_accessor :words

    # Initialize with a list of the categories for this clasifier
    def initialize(categories,user)
        @user = user
        @categories = categories
        @words = Hash.new # Hash of categories => hashes of word => count (in that category)
        @threshold = 3.5 # how much more likely x has to be than y to bother declaring it
        @categories.each { |category| @words[category] = Hash.new }
        @wordstems = Array.new
        @word_stash = ""
    end

    # Train the classifier!
    def train(category,document)
        word_count(document).each do |word,count|
            @user.total_words += count
            @user.save
            cat = category+"_words"
            @user.update_attribute(cat.to_sym, @user[cat.to_sym] + count)
            @words[category][word] ||= 0 # Stemming here would be redundant
            @words[category][word] += count
        end
        cat = category+"_docs"
        User.increment_counter cat.to_sym, @user.id
        @user.total_docs += 1
        @user.save
    end

    def compress_word_hash
        @categories.each do |category| 
            @words[category].each_key do |word|
                @wordstems.push word unless @wordstems.include? word
            end
        end 
        @wordstems.sort!
        @wordstems.each do |word|
            count1 = @words[@categories[0]][word] || 0
            count2 = @words[@categories[1]][word] || 0
            @word_stash << "#{word} #{count1} #{count2}\n"
        end
        @word_stash = Zlib::Deflate.deflate @word_stash
        @user.update_attribute :wordstems, @word_stash
    end

    def decompress_word_hash
        @word_stash = Zlib::Inflate.inflate @user.wordstems
        @wordstems = @word_stash.split(/\n/)
        @wordstems.each { |w| w = w.split }
        @wordstems.each do |w|
            @words[@categories[0]][w[0]] =  w[1]
            @words[@categories[0]][w[0]] =  w[2]
        end
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
        second_best[1] == 0 || best[1]/second_best[1] > @threshold ? best[0] : "Unknown"
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
        words = document.gsub(/-/," ").gsub(/[^a-zA-Z\s]/,"").gsub(/\s+/," ").split 
        word_hash = Hash.new
        words.each do |word|
            word.downcase!
            key = word.stem
            unless COMMON_WORDS.include? word # Remove common words
                word_hash[key] ||= 0
                word_hash[key] += 1 # Each word is a key, and maps to the count of how often it appears
            end
        end
        return word_hash
    end

    def word_probability(category,word)
        # The probability of a word in a category is the number of times it occurred 
        # in that category, divided by the number of words in that category altogether. 
        # Except we pretend every occured at least once per category, to avoid errors when encountering
        # words never encountered during training. (In latest draft, 0.0000000000000001 instead of 1)
        test_word = 0.0000000000000001
        test_word = @words[category][word].to_f unless !@words[category][word] || @words[category][word] == 0
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
    end

    # SIGNIFICANTLY trimmed down
    COMMON_WORDS = ['a','an','and','the','them','he','him','her','she','their','we',
        'to','be','some','on','or','by','i','this','that','for','in','into','what']
end