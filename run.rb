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

left, right = ['base', 'head'].map do |key|
  branch = event.fetch('pull_request').fetch(key)
  owner = branch.fetch('repo').fetch('owner').fetch('login')
  name = branch.fetch('repo').fetch('name')
  commit = branch.fetch('sha')

  p [key, owner, name, commit]

  yaml_files = `gh api graphql -F owner=#{owner} -F name=#{name} -F manifestsTree=#{commit}:kubernetes/manifests -f query=$( cat k8s-manifests-tree.gql ) | jq -r .. | grep yml$`
  yaml_files.sort.tap { |x| p x }
end

active = (left != right)

if active
  puts 'Added / removed manifests detected'
  content = File.read(File.expand_path('guidance.md', __dir__))
  writer.write(content)
else
  puts 'No added / removed manifests detected'
  writer.write(nil)
end
