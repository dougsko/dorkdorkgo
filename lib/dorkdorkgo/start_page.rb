module DorkDorkGo
    class StartPage
        include UserAgent

        def initialize(proxy: nil)
            RestClient.proxy = proxy
        end

        def search(q)
            @q = q
            links = []

            trap("INT") do 
                puts "Caught ctrl-c."
                return links.uniq
            end

            page = Nokogiri::HTML(RestClient.post("https://www.startpage.com/do/search", {'q' => q}))
            while true
                params = {}
                page.css('ol.web_regular_results li div p span.url').each do |link|
                    links << URI(link.text)
                    yield URI(link.text) if block_given?
                end
                puts "found " + links.size.to_s + " so far"

                page.css("div#nextnavbar input[type='hidden']").each do |link|
                    params[link['name']] = link['value']
                end
                sleep_time = rand(1..10)
                puts "sleeping for " + sleep_time.to_s
                sleep(sleep_time)
                begin
                    page = Nokogiri::HTML(RestClient.post("https://s3-us2.startpage.com/do/search", params, :user_agent => UserAgent.get_agent ))
                rescue RestClient::ExceptionWithResponse => err
                      err.response.follow_redirection
                rescue RestClient::Forbidden
                    puts "Forbidden"
                    break
                end
            end
            links
        end
    end
end



