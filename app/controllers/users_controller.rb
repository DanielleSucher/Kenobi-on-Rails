require 'askmeanswerscraper'
require 'askmequestionscraper'
require 'naivebayes'

class UsersController < ApplicationController

    def show
        @user = User.find(params[:id])
        session[:user_id] = @user.id
        @user.classify(1) # session[:pages] if you want to offer a choice of # of pages to classify instead
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
        # session[:pages] = params[:pages] (if offering the option of choosing n pages instead of defaulting to 1)
        # delete old records so Kenobi will retrain as needed
        @user.update_attribute(:wordstems, nil) if @user.updated_at < 6.months.ago
        if @user.wordstems
            # run the question scraper and classify the results
            @user.classify(1) # session[:pages] if you want to offer a choice of # of pages to classify instead
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
            flash[:training] = "Kenobi is busy analyzing your AskMeFi data to figure out what kinds of questions 
                you're best at answering! This can take ages, so please feel free to wander off and just have Kenobi 
                email you when ready."
            redirect_to root_path
        end
    end

    def check_status
        @user = User.where(:id => session[:user_id]).first
        if @user.training_status == "done"
            @user.classify(1) # session[:pages] if you want to offer a choice of # of pages to classify instead
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

    def email
        @user = User.where(:id => session[:user_id]).first
        @user.update_attribute :email, params[:email]
        respond_to do |format|  
            format.html { redirect_to root_path }  
            format.js 
        end  
    end
end


# Add this to the home page form if you want to offer the option of how many pages to classify:

#         <div class="field lower">
#             How many pages of new AskMe questions should Kenobi analyze for you?
#             <br />
#             <span class="form_select"><%= select_tag :pages, "<option>1</option><option>2</option><option>3</option>".html_safe %></span>
#         </div> 
