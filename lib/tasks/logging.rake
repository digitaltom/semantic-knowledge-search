# to get info about db statements use
# `rake verbose db:create`

namespace :log do
  desc 'switch rails logger to stdout'
  task stdout: :environment do
    Rails.logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
    ActiveRecord::Base.logger = Rails.logger.tagged('active-record')
  end

  desc 'switch rails logger log level to info'
  task info: %i[environment stdout] do
    ActiveRecord::Base.logger.level = Logger::INFO
    Rails.logger.level = Logger::INFO
  end

  desc 'switch rails logger log level to debug'
  task debug: %i[environment stdout] do
    ActiveRecord::Base.logger.level = Logger::DEBUG
    Rails.logger.level = Logger::DEBUG
  end
end
