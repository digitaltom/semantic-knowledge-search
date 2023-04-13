# enable sqlite vector search extension: https://github.com/asg017/sqlite-vss
ActiveRecord::Base.connection.raw_connection.enable_load_extension(true)
ActiveRecord::Base.connection.raw_connection.load_extension('./lib/vector0')
ActiveRecord::Base.connection.raw_connection.load_extension('./lib/vss0')

puts("Enabled sqlite vss extension " +
  ActiveRecord::Base.connection.execute('select vss_version()').to_s)
