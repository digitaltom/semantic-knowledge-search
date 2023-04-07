require 'ruby/openai'

class Article < ApplicationRecord

  scope :not_vectorized, -> { where(embedding: nil) }
  scope :vectorized, -> { where.not(embedding: nil) }
  scope :kb, -> { where("url like '%support/kb%'") }
  scope :doc, -> { where("url like '%documentation.suse.com%'") }

  def self.vectorize_all(reindex: false)
    articles = reindex ? all : not_vectorized
    articles.find_each do |a|
      a.vectorize
      # rate limit is 60/minute
      sleep(2)
    end
  end

  def vectorize
    openai = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    response = openai.embeddings(
      parameters: {
        model: "text-embedding-ada-002",
        input: text
      }
    )
    unless response['data']
      Rails.logger.error(response.inspect)
      return
      # raise Exception.new
    end
    self.embedding = response['data'][0]['embedding']
    self.vectorized_at = DateTime.now
    self.save!
    logger.info "Vectorized article '#{title}' with #{embedding.length} keys"
  end

end
