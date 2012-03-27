# Scraper to grab a user's Ask Metafilter answers and fav counts

class AskMeAnswerScraper
    attr_accessor :askme_id, :should_answer_training, :should_not_answer_training

    def initialize(user)
        @user = user
        @agent = Mechanize.new
        @agent.ca_file = "./lib/assets/cacert.pem" 
        @should_answer_training = []
        @should_not_answer_training = []
        @askme_answer_page_urls = []
    end

    def scrape_question_text(page)
        html = page.parser
        div = html.css('div.copy').first
        content = div.text.split(/$/)
        if content[1].include? "favorites"
            content = content[0].split("posted by")[0]
        else
            content[2] ? content = content[2].gsub(/\n|\r/,"") : content = "" 
        end
    end

    def parse_askme_answers
        # Parse the mechanize object
        html = @page.parser

        # collect the title of each question
        divs = html.css('div.copy')
        divs.pop #removes the next_page div from the end

        questions = []
        blockquotes = {}
        divs.each_with_index do |div,i|
            # adds the above-the-cut text of each question to the questions array
            # question_page = @agent.click(@page.link_with(:href => question_links[i][0]["href"]))
            question_page = @agent.click(@page.link_with(:href => div.search('a')[0]["href"]))
            content = self.scrape_question_text(question_page)
            questions << content
            # in each of those divs, each blockquote holds one answer
            if blockquotes[i]
                blockquotes[i] << div.search('blockquote')
            else
                blockquotes[i] = div.search('blockquote')
            end
        end
        
        # Now get the vote count for each div/question/answer 
        fav_counts = {}
        blockquotes.each do |key,val|
            val.each do |v|
                if fav_counts[key]
                    fav_counts[key] += v.css('span[id *= "favcnt"]').text.gsub(/\D/,"").to_i
                else
                    fav_counts[key] = v.css('span[id *= "favcnt"]').text.gsub(/\D/,"").to_i
                end
            end
            # currently sorts questions where the user's answer(s) got any favorites into should, 
            # and only those with no favs at all into should_not
            if fav_counts[key] > 0
                @should_answer_training << questions[key]
            else
                @should_not_answer_training << questions[key]
            end
        end
    end

    def collect_urls
        # adds url for each page of the user's askme answers to the array of urls
        html = @page.parser
        html.css('div[style="margin-left:30px;"] > a').each do |a|
            next_url = "/activity/#{@askme_id}/comments/ask/#{a.text}/" 
            @askme_answer_page_urls << next_url
        end
    end

    def get_askme_id
        page = @agent.get("https://login.metafilter.com/")
        # You have to log in before scraping in order to be able to search usernames
        login_form = page.form_with :action => 'logging-in.mefi'
        @user_name = "METAFILTER_USER_NAME"
        @user_pass = "METAFILTER_USER_PASSWORD"
        login_form.user_name = @user_name
        login_form.user_pass = @user_pass
        page = @agent.submit(login_form, login_form.buttons.first)
        page = @agent.click(page.link_with(:text => "Click here"))
        page = @agent.click(page.link_with(:text => "Search"))
        search_form = page.form_with :action => "/contribute/search.mefi"
        search_form.q = @user.name
        page = @agent.submit(search_form, search_form.buttons.first)
        page = @agent.click(page.link_with(:text => /Users\s\(\d+\)/))
        html = page.parser
        askme_id = html.search('div.copy')[1].search('a')[0]['href'].gsub(/[^\d]+/,"")
        @user.update_attribute :askme_id, askme_id
        @askme_id = @user.askme_id
    end

    def login_to_scrape_answers
    # Use Mechanize to connect securely 
        @agent = Mechanize.new
        @page = @agent.get(@url)
        @page = @agent.click(@page.link_with(:text => "Login"))
        # You have to log in before scraping in order to be able to see favcnt spans
        login_form = @page.form_with :action => 'logging-in.mefi'
        login_form.user_name = @user_name
        login_form.user_pass = @user_pass
        @page = @agent.submit(login_form, login_form.buttons.first)
    end

    def scrape_logged_in
        self.get_askme_id
        @url="http://www.metafilter.com/activity/#{@askme_id}/comments/ask/"
        self.login_to_scrape_answers
        # Parse the first page of answers
        @page = @agent.click(@page.link_with(:text => "Click here"))
        self.collect_urls
        self.parse_askme_answers
        # Parse the remaining pages of answers
        @askme_answer_page_urls.each do |url|
            @page = @agent.click(@page.link_with(:href => url))
            self.parse_askme_answers
        end
    end
end