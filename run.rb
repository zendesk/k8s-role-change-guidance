#!/usr/bin/env ruby
# frozen_string_literal: true

# No specific ruby version; only core dependencies
# (Using Javascript would fit better with the Github platform:
# https://docs.github.com/en/actions/creating-actions/creating-a-javascript-action)

require 'English'
require 'json'
require_relative './comment_writer'
require_relative './github_client'

magic_text = '<!-- k8s-role-change-guidance -->'

github_client = GithubClient.new
event = JSON.parse(File.read(ENV.fetch('GITHUB_EVENT_PATH')))
writer = CommentWriter.new(event, github_client, magic_text)

# HEAD is the PR's merge commit, not the PR's branch's head
# Assuming we're merging into main, then
# HEAD^1 is `main`, and HEAD^2 is the branch we're merging.
# HEAD^1..HEAD is therefore the change introduced by this PR.
added_or_removed_files = `git diff --stat --name-only -z --diff-filter=AD --no-rename HEAD^1..HEAD`
$CHILD_STATUS.success? or raise 'git diff failed'

active = added_or_removed_files.split("\0").any? { |path| path.start_with?('kubernetes/manifests/') }

if active
  content = File.read(File.expand_path('guidance.md', __dir__))
  writer.write(content)
else
  writer.write(nil)
end
