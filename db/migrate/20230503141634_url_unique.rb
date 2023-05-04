class UrlUnique < ActiveRecord::Migration[7.1]
  def change
    add_index :articles, :url, unique: true
    remove_column :articles, :file
    add_column :articles, :category, :string
  end
end
