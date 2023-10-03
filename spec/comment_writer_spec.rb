# frozen_string_literal: true

require 'json'
require_relative '../comment_writer'

RSpec.describe CommentWriter do
  let(:real_event) { JSON.parse(File.read(File.join(File.dirname(__FILE__), 'pull-1-opened-event.json'))) }
  let(:real_comments) { JSON.parse(File.read(File.join(File.dirname(__FILE__), 'pull-1-comments.json'))) }
  let(:real_url) { 'https://api.github.com/repos/zendesk/k8s-role-change-guidance/issues/1' }

  let(:github_client) { double('github-client') }
  let(:magic_text) { '<!-- k8s-role-change-guidance -->' }
  let(:guidance_text) { "the guidance text\n" }

  def with_magic(text)
    "#{magic_text}\n\n#{text}"
  end

  it 'can create a comment' do
    real_comments.first['body'] = 'just a normal comment'
    allow(github_client).to receive(:get)
      .with("#{real_url}/comments?per_page=100")
      .and_return(real_comments)
    expect(github_client).to receive(:post)
      .with("#{real_url}/comments", { body: with_magic('new comment') })
      .and_return({ 'url' => 'a-url' })
    writer = CommentWriter.new(real_event, github_client, magic_text)
    writer.write('new comment')
  end

  it 'can update a comment' do
    real_comments.first['body'] = with_magic('old version of the comment')
    allow(github_client).to receive(:get)
      .with("#{real_url}/comments?per_page=100")
      .and_return(real_comments)
    expect(github_client).to receive(:patch)
      .with(real_comments.first['url'], { body: with_magic('new comment') })
      .and_return({ 'url' => 'a-url' })
    writer = CommentWriter.new(real_event, github_client, magic_text)
    writer.write('new comment')
  end

  it "can leave a comment alone if it's already correct" do
    real_comments.first['body'] = with_magic('new comment')
    allow(github_client).to receive(:get)
      .with("#{real_url}/comments?per_page=100")
      .and_return(real_comments)
    writer = CommentWriter.new(real_event, github_client, magic_text)
    writer.write('new comment')
  end

  it 'can remove the existing comment' do
    real_comments.first['body'] = with_magic('new comment')
    allow(github_client).to receive(:get)
      .with("#{real_url}/comments?per_page=100")
      .and_return(real_comments)
    expect(github_client).to receive(:delete)
      .with(real_comments.first['url'])
    writer = CommentWriter.new(real_event, github_client, magic_text)
    writer.write(nil)
  end

  it 'can decline to add a comment, if none is needed' do
    real_comments.first['body'] = 'just a normal comment'
    allow(github_client).to receive(:get)
      .with("#{real_url}/comments?per_page=100")
      .and_return(real_comments)
    writer = CommentWriter.new(real_event, github_client, magic_text)
    writer.write(nil)
  end
end
