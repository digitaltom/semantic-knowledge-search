require 'vss0'

class CreateVssTable < ActiveRecord::Migration[7.1]
  ensure_vss0
  def up
    ActiveRecord::Base.connection.execute('CREATE VIRTUAL TABLE IF NOT EXISTS vss_articles using vss0(embedding(1536))')
  end
end
