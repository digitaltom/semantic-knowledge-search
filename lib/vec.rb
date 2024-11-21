require 'sqlite3'
require 'sqlite_vec'

def ensure_sqlite_vec
  db = ActiveRecord::Base.connection

  begin
    db.execute('select vec_version()')
  rescue ActiveRecord::StatementInvalid
    # enable sqlite vector search extension: https://alexgarcia.xyz/sqlite-vec/ruby.html
    db.raw_connection.enable_load_extension(true)
    SqliteVec.load(db.raw_connection)
    db.raw_connection.enable_load_extension(false)

    puts("Enabled sqlite vec extension " +
      db.execute('select vec_version()').to_s)
  end
end
