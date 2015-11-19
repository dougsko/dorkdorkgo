require "dorkdorkgo/version"
require 'nokogiri'
require 'rest-client'

class Dorkdorkgo
    def initialize(proxy: nil)
        @user_agent = "Mozilla/5.0 (Windows NT 5.1; rv:42.0) Gecko/20100101 Firefox/42.0"
        RestClient.proxy = proxy
    end

    def search(q)
        @q = q
        links = []
        RestClient.post("https://duckduckgo.com/html", {'q' => @q}, :user_agent => @user_agent ) do |response, request, result, &block|
            case response.code
            when 200
                page = Nokogiri::HTML(response.body)
                while true
                    params = {}
                    page.css('.links_main a').each do |link|
                        links << URI(link['href'])
                        yield URI(link['href']) if block_given?
                    end
                    puts "found " + links.size.to_s + " so far"
                    page.css("input[type='hidden']").each do |link|      
                        params[link['name']] = link['value']
                    end
                    sleep_time = rand(1..10)
                    puts "sleeping for " + sleep_time.to_s
                    sleep(sleep_time)
                    begin
                        page = Nokogiri::HTML(RestClient.post("https://duckduckgo.com/html", params, :user_agent => @user_agent ))
                    rescue RestClient::Forbidden
                        puts "Forbidden"
                        break
                    end
                end
            end
        end
        links
    end



end









