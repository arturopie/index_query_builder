require "bundler/gem_tasks"
require 'active_record'
require 'pg'

require 'index_query_builder'

namespace 'db:test' do

  desc 'Drop and create new test db and load schema'
  task :setup => [:drop, :create, :load_schema]

  task :drop do
    pg_connection = create_pg_connection
    pg_connection.query("DROP DATABASE IF EXISTS #{db_config[:database]}")
    pg_connection.close
  end

  task :create do
    pg_connection = create_pg_connection
    pg_connection.query("CREATE DATABASE #{db_config[:database]}")
    pg_connection.close
  end

  task :load_schema do
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Schema.define do
      create_table :posts, force: true do |t|
        t.text :title
        t.integer :view_count
      end

      create_table :comments, force: true do |t|
        t.integer :post_id
        t.text :text
        t.integer :likes
      end

      create_table :authors, force: true do |t|
        t.integer :comment_id
      end
    end
  end

  def create_pg_connection
    PG::Connection.open(
      host: db_config[:host], user: db_config[:username], password: db_config[:password], dbname: 'postgres'
    )
  end

  def db_config
   @db_config ||= IndexQueryBuilder.symbolize_keys(YAML.load_file('config/database.yml'))
  end
end
