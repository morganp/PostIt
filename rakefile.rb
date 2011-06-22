require 'rubygems'
require 'rake'
require 'active_record'
require 'logger'

namespace :db do
  desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"
  task :migrate => :environment do
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end

  desc "Migrate the database through scripts in db/migrate. DEVELOPMENT Mode"
  task :migrate_devel => :environment_devel do
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end
end

task :environment_devel do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'db/postits.db'
  )
  ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
end

task :environment do

  ## db = "postgres://username:password@hostname/database"
  db = ENV["DATABASE_URL"]
  if db.match(/postgres:\/\/(.*):(.*)@(.*)\/(.*)/) 
    username = $1
    password = $2
    hostname = $3
    database = $4

    ActiveRecord::Base.establish_connection(
      :adapter  => 'postgresql',
      :host     => hostname,
      :username => username,
      :password => password,
      :database => database
    )
  end
end
