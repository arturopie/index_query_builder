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

And you are building an index page for posts with the following requirements:
* Posts should be ordered by `view_count`.
* The user should be able to filter posts by texts in post's comments. For example, if `filters` is `{ comment_text: 'This post is amazing' }`, then we should return all the posts with a comment containing `'This post is amazing'`.
* More filters will be added soon.

Without Index Query Builder, you will probably have to do something like this.

```ruby
conditions_strings = []
conditions_params = {}

unless filters[:comment_text].blank?
  conditions_strings << "comments.text ILIKE :comment_text"
  conditions_params[:comment_text] = "%#{filters[:comment_text]}%"
end

conditions = (conditions_params.empty? ? "" : [conditions_strings.join(" AND "), conditions_params])

joins_list = []
joins_list << {:posts => :comment} if filters[:comment_text].present?

posts = Post.where(conditions).joins(joins_list).order("expected_ship_at desc, id desc")
```

Or, with Index Query Builder, you can just write this.

```ruby
posts = IndexQueryBuilder.query Post, with: filters do |query|
  query.filter_field [:comments, :text], contains: :comment_text
  query.order_by "view_count DESC"
end
```

## Operators

Operators will apply where clauses to query *only if* the filter_name is present in filters hash.

* :equal_to applies field_name = filter_value
* :contains applies substring (ILIKE '%filter_value%')
* :greater_than_or_equal_to applies field_name >= filter_value
* :less_than applies field_name < filter_value
* :present_if applies:
    * field_name IS NOT NULL if filter_value
    * field_name IS NULL if !filter_value

## Running tests

It requires PostgreSQL.

    $ cp config/database.yml.sample config/database.yml

Update `config/database.yml` with your connection information.

    $ rake db:test:setup
    $ rspec

## Contributing

1. Fork it ( https://github.com/arturopie/index_query_builder/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
