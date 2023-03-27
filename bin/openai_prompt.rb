#!/usr/bin/env ruby

# Howto:
# * `gem install ruby-openai dotenv optparse tty-markdown`
# * put you openai api token from https://platform.openai.com/account/api-keys
#   into a .env file or as OPENAI_API_KEY in your environment

require 'openai'
require 'dotenv/load'
require 'byebug'
require 'optparse'
require 'tty-markdown'

OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_API_KEY')
  config.request_timeout = 240
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{ARGV[0]} [options]"
  opts.on('-q', '--question QUESTION', 'Provide question as parameter') { |v| options[:q] = v }
  opts.on('-m', '--mode LANGUAGE', 'Answer in context of given programming language') { |v| options[:m] = v }
  opts.on('-d', '--debug', 'Debug mode') { |_v| options[:d] = true }
  opts.on('-l', '--lang', 'Language') { |_v| options[:l] = true }
  opts.on('-c', '--chat', 'Start an interactive conversation') { |_v| options[:chat] = true }
end.parse!

prompt = ''
prompt += "Answer in language #{options[:l]}." if options[:l]

prompt += "Act as a programming guide. Answer in context of the #{options[:m]} programming language. " if options[:m]

client = OpenAI::Client.new

if options[:chat]
  messages_history = []
  while true
    prompt = options[:q]
    unless options[:q]
      printf TTY::Markdown.parse('**Your message>** ')
      prompt = gets
    end
    options[:q] = nil
    messages_history << { "role": 'user', "content": prompt }
    parameters = {
      model: 'gpt-3.5-turbo',
      messages: messages_history,
      temperature: 0.3, # low temperature = very high probability response (0 to 1)
      max_tokens: 2000
    }
    puts "Sending: #{parameters}" if options[:d]
    response = client.chat(parameters:)
    puts "Received: #{response}" if options[:d]
    response = response['choices'][0]['message']['content']
    puts TTY::Markdown.parse("\n*ChatGPT response:* " + response)
    puts
    messages_history << { "role": 'assistant', "content": response }
  end
else
  prompt = options[:q]
  unless options[:q]
    printf TTY::Markdown.parse('**Your message>** ')
    prompt = gets
  end
  parameters = {
    model: 'text-davinci-003',
    prompt:,
    temperature: 0.3, # low temperature = very high probability response (0 to 1)
    max_tokens: 2000
  }
  puts "Sending: #{parameters}" if options[:d]
  response = client.completions(parameters:)
  puts "Received: #{response}" if options[:d]
end

begin
  puts TTY::Markdown.parse("\n*ChatGPT response:* " + response['choices'][0]['text'])
rescue StandardError
  puts "Cannot parse response :-( - '#{response['error']['message']}'"
end
