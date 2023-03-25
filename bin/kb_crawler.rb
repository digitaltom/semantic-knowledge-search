#!/usr/bin/env ruby

require 'byebug'
require 'open-uri'
require 'rubygems'
require 'nokogiri'

KB_IDS = 19_000..21_000

KB_IDS.each do |id|

  id = id.to_s.rjust(9, '0')
  uri = "https://www.suse.com/support/kb/doc/?id=#{id}"

  begin
    file = URI::open(uri)
    doc = Nokogiri::HTML(file)
    content = doc.css('#content').text.squeeze(" \n")
    title = doc.css('#content h1').text

    File.open("training/kb/kb-#{id}.txt", 'w') do |file|
      file.write(uri + "\n")
      file.write(title + "\n")
      file.write(content)
      puts "stored article '#{title}' from " + uri
    end

  rescue OpenURI::HTTPError => e
    puts "no article at " + uri
  end
end


