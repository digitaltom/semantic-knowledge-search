require 'vec'

class SqliteVecMigration < ActiveRecord::Migration[7.2]
  def up
    ensure_sqlite_vec
    db = ActiveRecord::Base.connection
    db.execute("CREATE VIRTUAL TABLE IF NOT EXISTS #{Article::EMBEDDINGS_TABLE} USING vec0(embedding float[#{Llm::Api.create.class::MAX_EMBEDDINGS}])")
  end

  def down
    ensure_sqlite_vec
    db = ActiveRecord::Base.connection
    db.execute("DROP TABLE IF EXISTS #{Article::EMBEDDINGS_TABLE}")
  end
end
