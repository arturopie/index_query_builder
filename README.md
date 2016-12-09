# IndexQueryBuilder

This gem provides a DSL on top of ActiveRecord to get collection of models for index pages with filters.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'index_query_builder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install index_query_builder

## Usage

Let's say you have the following schema:

```ruby
create_table :posts, force: true do |t|
  t.text :title
  t.integer :view_count
end

create_table :comments, force: true do |t|
  t.integer :post_id
  t.text :text
end
```

And the following models

```ruby
class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end
```

And you are building an index page for posts with following requirements:
* Order posts by `view_count`.
* Have a filter for the texts in comments of that post.

You can write this

```ruby
posts = IndexQueryBuilder.query Post, with: filters do |query|
  query.filter_field [:comments, :text], contains: :comment_text
  query.order_by "view_count DESC"
end
```

Where the `filters` variable is a hash containing the `comment_text` key. For example, if `filters` is `{ comment_text: 'This post is amazing' }`, then `posts.to_a` will return all the posts with a comment containing `'This post is amazing'`.

## Running tests

    $ rake db:test:setup
    $ rspec

## Contributing

1. Fork it ( https://github.com/arturopie/index_query_builder/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
