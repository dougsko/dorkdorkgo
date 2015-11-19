require "dorkdorkgo/version"
require "dorkdorkgo/user_agent"
require 'nokogiri'
require 'rest-client'

class Dorkdorkgo
    include UserAgent

    def initialize(proxy: nil)
        RestClient.proxy = proxy
    end

    def search(q)
        @q = q
        links = []

        trap("INT") do 
            puts "Caught ctrl-c."
            return links
        end

        page = Nokogiri::HTML(RestClient.post("https://duckduckgo.com/html", {'q' => @q}, :user_agent => get_agent ))
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
                page = Nokogiri::HTML(RestClient.post("https://duckduckgo.com/html", params, :user_agent => get_agent ))
            rescue RestClient::Forbidden
                puts "Forbidden"
                break
            end
        end
        links
    end
end












