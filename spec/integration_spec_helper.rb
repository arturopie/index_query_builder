require 'spec_helper'
require 'index_query_builder'
require 'active_record'

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
  has_one :author
end

class Author < ActiveRecord::Base
  belongs_to :post
end

ActiveRecord::Base.establish_connection(YAML.load_file('config/database.yml'))

RSpec.configure do |config|
  config.before(:each) do
    Post.delete_all
    Comment.delete_all
    Author.delete_all
  end
end
