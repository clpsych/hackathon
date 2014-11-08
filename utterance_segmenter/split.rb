#!/usr/bin/env ruby
require 'find'
require 'json'
require 'cgi'
require 'fileutils'

batch_size = (ARGV[2] || "100000").to_i
out_dir = ARGV[1]
FileUtils.mkdir_p(out_dir)

bad_chars = Regexp.new([0xC2, 0x85].pack('C*').force_encoding('ASCII-8BIT'))
out_tweets = File.open(File.join(out_dir, "0.tweets.txt"), "w")
out_ids = File.open(File.join(out_dir, "0.ids.txt"), "w")
count = 0
Find.find(ARGV[0]) do |f| 
  if f =~ /\.tweets/
    puts f
    File.open(f, "r") do |ff|
      while ff.gets
        json = JSON.parse($_)
        #at least remove newlines, even if it can't be unescaped
        #text = json["text"].bytes.map {|b| b == 0x09 || b == 0x0a || b == 0x0d ? 0x20 : b }.pack('C*').force_encoding('utf-8')
        
        text = CGI.unescapeHTML(CGI.unescapeHTML(json["text"].force_encoding('ASCII-8BIT'))).gsub(/&nbsp;/, ' ').gsub(bad_chars, ' ').gsub(/\s+/, ' ').strip.split(' ').map do |blob|
          blob = blob.force_encoding('UTF-8')
          begin
            blob.gsub(/[[:space:]]:+/, ' ').strip
          rescue ArgumentError
            blob
          end
        end.select { |x| x.length > 0 }.join(' ')
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
