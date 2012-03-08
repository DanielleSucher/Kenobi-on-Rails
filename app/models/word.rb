class Word < ActiveRecord::Base
	attr_accessible :user_id, :wordstem, :should, :should_not
    belongs_to :users

    validates_presence_of :user_id, :wordstem, :should, :should_not
    validates_numericality_of :should, :should_not

end
