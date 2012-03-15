require 'askmeanswerscraper'
require 'askmequestionscraper'
require 'naivebayes'

class UsersController < ApplicationController

    def new
        redirect_to root_path
    end

    def classify

        @user = User.where(:askme_id => params[:askme_id]).first || 
            User.create!(:askme_id => params[:askme_id])
        session[:askme_id] = params[:askme_id]
        session[:user_id] = @user.id
        session[:pages] = params[:pages]
        # delete old records so Kenobi will retrain as needed
        @user.words.where(['updated_at < ?', 6.months.ago]).destroy_all 
        if @user.words.first != nil
            # run the question scraper and classify the results
            @user.classify(session[:pages])
            if !@user.results || @user.results == []
                flash[:error] = "Sorry, something went wrong! This probably means that you're just no good at 
                                    answering AskMeFi questions yet."
                redirect_to results_path
            else
                flash[:success] = "Kenobi has picked out the AskMeFi questions that you can answer best!"
                redirect_to results_path
            end
        else
            # train Kenobi when classifying new or out-of-date users
            @user.delay.train unless @user.training_status == "started"
            flash[:training] = "Please be patient - Kenobi is busy analyzing your AskMeFi data to figure out 
                                    what kinds of questions you're best at answering!"
            redirect_to root_path
        end
    end

    def check_status
        @user = User.where(:id => session[:user_id]).first
        if @user.training_status == "done"
            @user.classify(session[:pages])
            if !@user.results || @user.results == []
                flash[:error] = "Sorry, something went wrong! This probably means that you're just no good at 
                                    answering AskMeFi questions yet."
                render :json => { 'status' => "ready" }
            else
                flash[:success] = "Kenobi has picked out the AskMeFi questions that you can answer best!"
                render :json => { 'status' => "ready" }
            end
        else
            render :json => { 'status' => @user.training_status }
        end
    end
end
