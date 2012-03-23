module SessionsHelper

  private
  	
  	def results=(array)
    	session[:results] = array
  	end
    
    def reset_results
    	session[:results] = []
    end
end