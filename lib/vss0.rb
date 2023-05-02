def ensure_vss0
  begin
    ActiveRecord::Base.connection.execute('select vss_version()')
  rescue ActiveRecord::StatementInvalid
    ActiveRecord::Base.connection.raw_connection.enable_load_extension(true)
    ActiveRecord::Base.connection.raw_connection.load_extension('./lib/vector0')
    ActiveRecord::Base.connection.raw_connection.load_extension('./lib/vss0')
    Rails.logger.info("Enabled sqlite vss extension " +
      ActiveRecord::Base.connection.execute('select vss_version()').to_s)
  end
end
