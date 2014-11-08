#!/usr/bin/env ruby
require 'find'
require 'json'
require 'cgi'
require 'fileutils'

batch_size = 1000000
out_dir = ARGV[1]
FileUtils.mkdir_p(out_dir)

out_tweets = File.open(File.join(out_dir, "0.tweets.txt"), "w")
out_ids = File.open(File.join(out_dir, "0.ids.txt"), "w")
count = 0
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
          count += 1
          if count % batch_size == 0
            batch = (count / batch_size).to_s
            [out_tweets, out_ids].each { |g| g.close}
            out_tweets = File.open(File.join(out_dir, batch + ".tweets.txt"), "w")
            out_ids = File.open(File.join(out_dir, batch + ".ids.txt"), "w")
          end
        end
      end
    end
  end
end
out_tweets.close
out_ids.close
