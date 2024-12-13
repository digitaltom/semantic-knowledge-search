require 'ruby/openai'
require 'sqlite_vec'
require 'vec'

class Article < ApplicationRecord

  scope :not_vectorized, -> { where(embedding: nil) }
  scope :vectorized, -> { where.not(embedding: nil) }
  scope :kb, -> { where(category: 'kb') }
  scope :doc, -> { where(category: 'doc') }
  scope :gh, -> { where(category: 'github') }
  scope :trello, -> { where(category: 'trello') }

  after_save :vectorize_on_text_update
  after_destroy :destroy_article_text_embedding

  EMBEDDINGS_TABLE = "article_text_embeddings"

  def self.vectorize_all(reindex: false)
    articles = reindex ? all : not_vectorized
    articles.find_each do |a|
      a.vectorize!
      # rate limit is 60/minute
      sleep(2)
    end
  end

  def vectorize_on_text_update
    vectorize! if saved_change_to_text?
    update_embeddings_table if saved_change_to_embedding?
  end

  def vectorize!
    logger.info "Vectorizing article #{url}"
    self.embedding = Llm::Api.create.embeddings(text)
    self.vectorized_at = DateTime.now
    self.save!
    logger.info "Vectorized article '#{title}' with #{embedding.length} keys"
  end

  def article_text_embedding
    ensure_sqlite_vec
    db = ActiveRecord::Base.connection.raw_connection
    db.execute("select * from #{EMBEDDINGS_TABLE} where rowid = #{id}")
  end

  def update_embeddings_table
    db = ActiveRecord::Base.connection.raw_connection
    ensure_sqlite_vec
    destroy_article_text_embedding
    db.execute("INSERT INTO #{EMBEDDINGS_TABLE}(rowid, embedding) VALUES (?, ?)",
      [id, embedding.pack("f*")])
  end

  def destroy_article_text_embedding
    ensure_sqlite_vec
    db = ActiveRecord::Base.connection.raw_connection
    db.execute("delete from #{EMBEDDINGS_TABLE} where rowid = #{id}")
  end

end
