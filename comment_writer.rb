# frozen_string_literal: true

# No specific ruby version; only core dependencies
# (Using Javascript would fit better with the Github platform:
# https://docs.github.com/en/actions/creating-actions/creating-a-javascript-action)

class CommentWriter
  def initialize(event, github_client, magic_text)
    @event = event
    @github_client = github_client
    @magic_text = magic_text
  end

  attr_reader :event, :github_client, :magic_text

  def write(comment_text)
    update_pr(comment_text, find_existing_comment)
  end

  private

  def find_existing_comment
    url = event.fetch('pull_request').fetch('comments_url')

    # TODO: pagination
    url += '?per_page=100'

    comments = github_client.get(url)
    comment = comments.find { |c| c.fetch('body').include?(magic_text) }

    if comment
      puts "Found existing comment #{comment.fetch('url')}"
    else
      puts 'No existing comment'
    end

    comment
  end

  def update_pr(comment_text, existing_comment)
    comment_text = "#{magic_text}\n\n#{comment_text}" unless comment_text.nil?

    if !comment_text.nil? && existing_comment.nil?
      url = event.fetch('pull_request').fetch('comments_url')
      c = github_client.post(url, { body: comment_text })
      puts "Created comment #{c.fetch('url')}"
    elsif !comment_text.nil?
      if existing_comment.fetch('body') == comment_text
        puts 'Comment is already correct'
      else
        c = github_client.patch(existing_comment.fetch('url'), { body: comment_text })
        puts "Updated comment #{c.fetch('url')}"
      end
    elsif existing_comment
      github_client.delete(existing_comment.fetch('url'))
      puts "Deleted comment #{existing_comment.fetch('url')}"
    else
      puts 'Nothing to do'
    end
  end
end
