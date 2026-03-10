require 'active_record'
require 'dotenv'

Dotenv.load

module Database
  def self.connect
    db_url = ENV['DATABASE_URL']
    
    if db_url
      ActiveRecord::Base.establish_connection(db_url)
    else
      ActiveRecord::Base.establish_connection(
        adapter: 'postgresql',
        host: ENV.fetch('DB_HOST', 'localhost'),
        port: ENV.fetch('DB_PORT', 5432),
        database: ENV.fetch('DB_NAME', 'wishlist_web_db'),
        username: ENV.fetch('DB_USER', 'postgres'),
        password: ENV.fetch('DB_PASSWORD', 'postgres')
      )
      
      # Очищаем кэш схемы, чтобы ActiveRecord увидел новые таблицы
      ActiveRecord::Base.connection.schema_cache.clear!
      ActiveRecord::Base.connection.schema_cache.refresh!
    end
  end
end

