#!/usr/bin/env ruby

require "ruby/openai"
require 'dotenv/load'
require 'byebug'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{ARGV[0]} [options]"
  opts.on('-q', '--question QUESTION', 'Provide question as parameter') { |v| options[:q] = v }
  opts.on('-m', '--mode MODE', 'Mode [default|ruby]') { |v| options[:m] = v }
  opts.on('-d', '--debug', 'Debug mode') { |v| options[:d] = true }
  opts.on('-l', '--lang', 'Language') { |v| options[:l] = true }
end.parse!

prompt = options[:q]
unless options[:q]
  puts "Ask it!"
  prompt = gets
end

if options[:l]
  prompt += "Please answer in #{options[:l]}"
end

if options[:m]
  prompt += "Please answer with an example in Ruby programming language."
end


client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
parameters = {
  model: "text-davinci-003",
  prompt: prompt,
  temperature: 0.4, # low temperature = very high probability response
  max_tokens: 2000
}

puts "Sending: #{parameters.to_s}" if options[:d]
response = client.completions(parameters: parameters)
puts "Received: #{response}" if options[:d]

puts response['choices'][0]['text']
