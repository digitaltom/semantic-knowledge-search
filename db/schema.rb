# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_11_20_212338) do
# Could not dump table "article_text_embeddings" because of following StandardError
#   Unknown type '' for column 'rowid'


  create_table "article_text_embeddings_chunks", primary_key: "chunk_id", force: :cascade do |t|
    t.integer "size", null: false
    t.binary "validity", null: false
    t.binary "rowids", null: false
  end

# Could not dump table "article_text_embeddings_info" because of following StandardError
#   Unknown type 'ANY' for column 'value'


# Could not dump table "article_text_embeddings_rowids" because of following StandardError
#   Unknown type '' for column 'id'


# Could not dump table "article_text_embeddings_vector_chunks00" because of following StandardError
#   Unknown type '' for column 'rowid'


  create_table "articles", force: :cascade do |t|
    t.string "url"
    t.string "title"
    t.json "embedding"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "vectorized_at"
    t.datetime "indexed_at"
    t.string "category"
    t.index ["url"], name: "index_articles_on_url", unique: true
  end
end
