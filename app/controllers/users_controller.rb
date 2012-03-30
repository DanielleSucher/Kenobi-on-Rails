require 'askmeanswerscraper'
require 'naivebayes'

class UsersController < ApplicationController

    def show
        @user = User.find(params[:id])
        session[:user_id] = @user.id
        @user.classify # session[:pages] if you want to offer a choice of # of pages to classify instead
        if !@user.results || @user.results == []
            flash[:error] = "Sorry, something went wrong! This probably means that you're just no good at 
                                answering AskMeFi questions yet."
            redirect_to results_path
        else
            flash[:success] = "Kenobi has picked out the AskMeFi questions that you can answer best!"
            redirect_to results_path
        end
    end

    def classify
        @user = User.where(:name => params[:name].downcase).first || 
            User.create!(:name => params[:name].downcase)
        session[:user_id] = @user.id
        # delete old records so Kenobi will retrain as needed
        @user.update_attribute(:wordstems, nil) if @user.updated_at < 6.months.ago
        if @user.wordstems
            # run the question scraper and classify the results
            @user.classify
            if !@user.results || @user.results == []
                flash[:error] = "Kenobi couldn't find any new questions that you should answer this time! Either
                    you just haven't answered enough questions yet to give Kenobi sufficient data to work with, or the
                    current front page is just a bad batch for you. Sorry!"
                redirect_to results_path
            else
                flash[:success] = "Kenobi has picked out the AskMeFi questions that you can answer best!"
                redirect_to results_path
            end
        else
            # train Kenobi when classifying new or out-of-date users
            @user.delay.train unless @user.training_status == "started"
            flash[:training] = "Kenobi is busy analyzing your AskMeFi data to figure out what kinds of questions 
                you're best at answering! This can take ages, so please feel free to wander off and just have Kenobi 
                email you when ready."
            redirect_to root_path
        end
    end

    def check_status
        @user = User.where(:id => session[:user_id]).first
        if @user.training_status == "done"
            @user.classify
            if !@user.results || @user.results == []
                flash[:error] = "Kenobi couldn't find any new questions that you should answer this time! Either
                    you just haven't answered enough questions yet to give Kenobi sufficient data to work with, or the
                    current front page is just a bad batch for you. Sorry!"
                render :json => { 'status' => "ready" }
            else
                flash[:success] = "Kenobi has picked out the AskMeFi questions that you can answer best!"
                render :json => { 'status' => "ready" }
            end
        elsif @user.training_status == "name_not_found"
            flash[:error] = "Sorry, Kenobi couldn't find the username you entered when searching Ask Metafilter!"
            render :json => { 'status' => "ready" }
        else
            render :json => { 'status' => @user.training_status }
        end
    end

    def email
        @user = User.where(:id => session[:user_id]).first
        @user.update_attribute :email, params[:email]
        respond_to do |format|  
            format.html { redirect_to root_path }  
            format.js 
        end  
    end
end