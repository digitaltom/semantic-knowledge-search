require 'ruby/openai'
require 'vss0'

class Article < ApplicationRecord

  scope :not_vectorized, -> { where(embedding: nil) }
  scope :vectorized, -> { where.not(embedding: nil) }
  scope :kb, -> { where("url like '%support/kb%'") }
  scope :doc, -> { where("url like '%documentation.suse.com%'") }

  after_save :update_vss_article
  after_destroy :destroy_vss_article

  def self.vectorize_all(reindex: false)
    articles = reindex ? all : not_vectorized
    articles.find_each do |a|
      a.vectorize!
      # rate limit is 60/minute
      sleep(2)
    end
  end

  def vectorize!
    openai = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    response = openai.embeddings(
      parameters: {
        model: "text-embedding-ada-002",
        input: text
      }
    )
    unless response['data']
      Rails.logger.error(response.inspect)
      raise Exception.new("Vectorizing article #{id} failed")
    end
    # embedding size from openai is 1536
    self.embedding = response['data'][0]['embedding']
    self.vectorized_at = DateTime.now
    self.save!
    logger.info "Vectorized article '#{title}' with #{embedding.length} keys"
  end

  def vss_article
    ensure_vss0
    ActiveRecord::Base.connection.execute("select * from vss_articles where rowid = #{id}")
  end

  def update_vss_article
    ensure_vss0
    ActiveRecord::Base.connection.execute("delete from vss_articles where rowid = #{id}")
    ActiveRecord::Base.connection.execute("insert into vss_articles(rowid, embedding) values(#{id}, '#{embedding}')")
  end

  def destroy_vss_article
    ensure_vss0
    ActiveRecord::Base.connection.execute("delete from vss_articles where rowid = #{id}")
  end

end
