require 'ruby/openai'
require 'cosine_similarity'
require 'vec'

class Question

  attr_reader :question

  def initialize(question)
    @question = question
  end

  def embedding
    Rails.cache.fetch("question_embedding_#{question}", expires_in: 48.hours) do
      embedding = Llm::Api.create.embeddings(question)
      Rails.logger.info("Generated embedding for '#{@question}' (#{embedding.size} vectors)")
      embedding
    end
  end

  # With vss=true, semantic search is using the sqlite3 vector similarity query.
  # With vss=false it falls back to cosine_similarity search over all articles
  def related_articles(vss: true)
    if vss
      Rails.cache.fetch("articles_#{embedding}", expires_in: 48.hours) do
        db = ActiveRecord::Base.connection.raw_connection
        ensure_sqlite_vec
        begin
          db.execute(<<-SQL, [embedding.pack("f*")])
            SELECT rowid as article_id, distance
            FROM #{Article::EMBEDDINGS_TABLE}
            WHERE embedding MATCH ?
            ORDER BY distance
            LIMIT 5
          SQL
        rescue => e
          # vss raises on select on empty db
          []
        end
      end
    else
      results = []
      Article.vectorized.find_each do |article|
        similarity = cosine_similarity(embedding, article.embedding) * 100
        similarity -= 2 if article.file =~ /kb/
        similarity = similarity.round(2)
        results << {'similarity' => similarity, 'article_id' => article.id}
      end
      results.sort_by{|r| r['similarity']}.reverse[0..4]
    end
  end

end
