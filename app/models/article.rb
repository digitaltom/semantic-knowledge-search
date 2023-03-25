require 'ruby/openai'

class Article < ApplicationRecord

  def self.import_all(reindex: false)
    Dir.glob("storage/training/**/*.txt") do |file|
      from_file(file, reindex: reindex)
    end
  end

  def self.from_file(file, reindex: false)
    if Article.find_by(file: file) && !reindex
      return Article.find_by(file: file)
    end

    article = Article.find_by(file: file) || Article.new
    article.file = file
    article.url = File.readlines(file)[0]
    article.title = File.readlines(file)[1]
    article.text = File.read(file).dump().split[0..1200].join(' ')

    openai = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

    response = openai.embeddings(
      parameters: {
        model: "text-embedding-ada-002",
        input: article.text
      }
    )

    unless response['data']
      Rails.logger.error(response.inspect)
      return
      # raise Exception.new
    end
    # rate limit is 60/minute
    sleep(2)

    article.embedding = response['data'][0]['embedding']
    article.save!
    logger.info "Created article with #{article.embedding.length} keys from #{article.file}"
    article
  end

end
