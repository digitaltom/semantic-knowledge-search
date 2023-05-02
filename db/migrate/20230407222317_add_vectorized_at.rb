class AddVectorizedAt < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :vectorized_at, :datetime
    add_column :articles, :indexed_at, :datetime
  end
end
