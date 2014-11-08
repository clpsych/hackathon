#!/usr/bin/env ruby
require 'find'
require 'json'
require 'cgi'

out_tweets = File.open(ARGV[1], "w")
out_ids = File.open(ARGV[2], "w")
Find.find(ARGV[0]) do |f| 
  if f =~ /\.tweets/
    puts f
    File.open(f, "r") do |ff|
      while ff.gets
        json = JSON.parse($_)
        begin
          text = CGI.unescapeHTML(json["text"]).gsub(/\s+/, ' ').strip
        rescue ArgumentError
          text = json["text"]
        end
        if text.length > 0
          out_ids.puts json["id"]
          out_tweets.puts text
        end
      end
    end
  end
end
out_tweets.close
out_ids.close
