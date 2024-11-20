require 'sqlite3'
require 'sqlite_vec'

# enable sqlite vector search extension: https://alexgarcia.xyz/sqlite-vec/ruby.html
ActiveRecord::Base.connection.raw_connection.enable_load_extension(true)
SqliteVec.load(ActiveRecord::Base.connection.raw_connection)
ActiveRecord::Base.connection.raw_connection.enable_load_extension(false)

puts("Initialized sqlite vec extension " +
  ActiveRecord::Base.connection.execute('select vec_version()').to_s)
