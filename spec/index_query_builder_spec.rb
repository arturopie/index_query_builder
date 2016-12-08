require 'rspec'
require 'integration_spec_helper'

RSpec.describe IndexQueryBuilder do
  describe 'operator :contains' do
    it 'returns records containing filter value' do
      Post.create!(title: "Using Rubymine because it's awesome")
      Post.create!(title: "VIM is useless")

      posts = IndexQueryBuilder.query Post.where(nil), with: { title: 'Rubymine' } do |query|
        query.filter_field :title, contains: :title
      end

      expect(posts.length).to eq(1)
      expect(posts[0].title).to eq("Using Rubymine because it's awesome")
    end

    it 'filters using association' do
      Post.create!(comments: [Comment.create!(text: "This post is amazing.")])

      posts = IndexQueryBuilder.query Post.where(nil), with: { comment_text: 'amazing' } do |query|
        query.filter_field [:comments, :text], contains: :comment_text
      end

      expect(posts.length).to eq(1)
    end
  end

  describe 'operator :equal_to' do
    it 'returns records equal to filter value' do
      Post.create!(title: "Using Rubymine because it's awesome")
      Post.create!(title: "VIM is useless")

      posts = IndexQueryBuilder.query Post.where(nil), with: { title: "Using Rubymine because it's awesome" } do |query|
        query.filter_field :title, equal_to: :title
      end

      expect(posts.length).to eq(1)
      expect(posts[0].title).to eq("Using Rubymine because it's awesome")
    end

    it 'filters using association' do
      Post.create!(comments: [Comment.create!(text: "This post is amazing.")])

      posts = IndexQueryBuilder.query Post.where(nil), with: { comment_text: "This post is amazing." } do |query|
        query.filter_field [:comments, :text], equal_to: :comment_text
      end

      expect(posts.length).to eq(1)
    end
  end

  describe 'operator :greater_than_or_equal_to' do
    it 'returns records greater than or equal to filter value' do
      Post.create!(view_count: 10)
      Post.create!(view_count: 1)
      Post.create!(view_count: 5)

      result = IndexQueryBuilder.query Post.where(nil), with: { view_count: 5 } do |query|
        query.filter_field :view_count, greater_than_or_equal_to: :view_count
      end

      posts = result.sort_by(&:view_count)
      expect(posts.length).to eq(2)
      expect(posts[0].view_count).to eq(5)
      expect(posts[1].view_count).to eq(10)
    end

    it 'filters using association' do
      Post.create!(comments: [Comment.create!(likes: 5)])
      posts = IndexQueryBuilder.query Post.where(nil), with: { likes: 3 } do |query|
        query.filter_field [:comments, :likes], greater_than_or_equal_to: :likes
      end

      expect(posts.length).to eq(1)
    end
  end

  describe 'operator :less_than' do
    it 'returns records less than filter value' do
      Post.create!(view_count: 10)
      Post.create!(view_count: 1)
      Post.create!(view_count: 5)

      posts = IndexQueryBuilder.query Post.where(nil), with: { view_count: 5 } do |query|
        query.filter_field :view_count, less_than: :view_count
      end

      expect(posts.length).to eq(1)
      expect(posts[0].view_count).to eq(1)
    end

    it 'filters using association' do
      Post.create!(comments: [Comment.create!(likes: 5)])
      posts = IndexQueryBuilder.query Post.where(nil), with: { likes: 6 } do |query|
        query.filter_field [:comments, :likes], less_than: :likes
      end

      expect(posts.length).to eq(1)
    end
  end

  describe 'operator :less_than_or_equal_to' do
    it 'returns records less than or equal to the filter value' do
      Post.create!(view_count: 10)
      Post.create!(view_count: 1)
      Post.create!(view_count: 5)

      posts = IndexQueryBuilder.query Post.where(nil), with: { view_count: 5 } do |query|
        query.filter_field :view_count, less_than_or_equal_to: :view_count
      end

      expect(posts.length).to eq(2)
      expect(posts[0].view_count).to eq(1)
      expect(posts[1].view_count).to eq(5)
    end

    it 'filters using association' do
      Post.create!(comments: [Comment.create!(likes: 5)])
      posts = IndexQueryBuilder.query Post.where(nil), with: { likes: 5  } do |query|
        query.filter_field [:comments, :likes], less_than_or_equal_to: :likes
      end

      expect(posts.length).to eq(1)
    end
  end

  describe 'operator :present_if' do
    it 'returns records where field is not null' do
      hit = Post.create!(view_count: 0)
      Post.create!(view_count: nil)

      posts = IndexQueryBuilder.query Post.where(nil), with: { has_view_count: true } do |query|
        query.filter_field :view_count, present_if: :has_view_count
      end

      expect(posts.length).to eq(1)
      expect(posts[0]).to eq(hit)
    end

    it 'returns records where field is null' do
      hit = Post.create!(view_count: nil)
      Post.create!(view_count: 0)

      posts = IndexQueryBuilder.query Post.where(nil), with: { has_view_count: false } do |query|
        query.filter_field :view_count, present_if: :has_view_count
      end

      expect(posts.length).to eq(1)
      expect(posts[0]).to eq(hit)
    end

    it 'filters using association' do
      Post.create!(comments: [Comment.create!(likes: nil)])
      posts = IndexQueryBuilder.query Post.where(nil), with: { has_comment_likes: false } do |query|
        query.filter_field [:comments, :likes], present_if: :has_comment_likes
      end

      expect(posts.length).to eq(1)
    end
  end

  it "raises UnknownOperator when passed operator is not supported" do
    expect do
      IndexQueryBuilder.query Post.where(nil) do |query|
        query.filter_field :view_count, unkown_operator: :view_count
      end
    end.to raise_error(IndexQueryBuilder::UnknownOperator, /unkown_operator/)
  end

  it "does not error when passing unknown filter name" do
    IndexQueryBuilder.query(Post.where(nil), with: {unknown_filter: "aaa"}) { |_| }
  end

  it "order_by works" do
    Post.create(view_count: 5)
    Post.create(view_count: 1)
    Post.create(view_count: 10)

    posts = IndexQueryBuilder.query Post.where(nil) do |query|
      query.order_by "view_count DESC"
    end

    expect(posts.length).to eq(3)
    expect(posts[0].view_count).to eq(10)
    expect(posts[1].view_count).to eq(5)
    expect(posts[2].view_count).to eq(1)
  end

  it "returns arel object" do
    Post.create!(view_count: 10)

    result = IndexQueryBuilder.query(Post.where(nil)) { |_| }

    posts = result.where(view_count: 10)
    expect(posts.length).to eq(1)
    expect(posts[0].view_count).to eq(10)
  end

  it "works with filter names as string" do
    Post.create!(view_count: 1)

    posts = IndexQueryBuilder.query Post.where(nil), with: { "view_count" => 5 } do |query|
      query.filter_field :view_count
    end

    expect(posts.length).to eq(0)
  end

  describe ".query_children" do
    # IQB_TODO: write tests for number of queries
    it "works" do
      Post.create!(comments: [Comment.create!(likes: 5)])
      Post.create!(comments: [Comment.create!(likes: 10)])

      comments = IndexQueryBuilder.query_children(:comments, Post.where(nil), with: { likes: 10 }) do |query|
        query.filter_field [:comments, :likes], equal_to: :likes
      end

      expect(comments.length).to eq(1)
      expect(comments[0].likes).to eq(10)
    end
  end
end
