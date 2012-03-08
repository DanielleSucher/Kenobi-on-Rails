class Result < ActiveRecord::Base
	attr_accessible :user_id, :url, :content
    belongs_to :users

    validates_presence_of :user_id, :url, :content
end
