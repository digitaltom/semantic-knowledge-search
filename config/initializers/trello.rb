require 'trello'

Trello.configure do |config|
  config.developer_public_key = ENV.fetch('TRELLO_KEY', nil)
  config.member_token = ENV.fetch('TRELLO_TOKEN', nil)
end
