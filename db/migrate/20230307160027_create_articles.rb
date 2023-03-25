class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :file, unique: true
      t.string :url, unique: true
      t.string :title
      t.json :embedding
      t.string :text

      t.timestamps
    end
  end
end
