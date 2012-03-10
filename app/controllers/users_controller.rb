require 'askmeanswerscraper'
require 'askmequestionscraper'
require 'naivebayes'

class UsersController < ApplicationController

    def new
        redirect_to root_path
    end

    # def retrain
    #     @user = User.where(:askme_id => params[:askme_id]).first || User.create!(:askme_id => params[:askme_id])
    #     @user.train # run the answer scraper and train Kenobi on the results
    #     if @user.save
    #         flash[:success] = "Thank you for helping Kenobi learn to help you be most effective in helping others!"
    #         redirect_to root_path
    #     else
    #         flash[:error] = "Sorry, something went wrong!"
    #         redirect_to root_path
    #     end
    # end

    def classify
        @user = User.where(:askme_id => params[:askme_id]).first || 
            User.create!(:askme_id => params[:askme_id])
        session[:user_id] = @user.id
        Word.where(['updated_at > ?', 6.months.ago] && :user_id => @user.id).destroy_all # delete old records so Kenobi will retrain as needed
        @user.train if !Word.where(:user_id => @user.id).first # train Kenobi when classifying new or out-of-date users
        # run the question scraper and classify the results
        @user.classify(params[:pages])
        if @user.results != nil || []
            flash[:success] = "Kenobi has picked out the AskMe questions that you can answer best!"
            redirect_to results_path
        else
            flash[:error] = "Sorry, something went wrong!"
            redirect_to root_path
        end
    end
end
