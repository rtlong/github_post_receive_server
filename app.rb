# -*- coding: utf-8 -*-
#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'json'
require 'net/smtp'
require 'yaml'
require './email'

# load the file that tells the app who to email
SUBSCRIPTIONS = YAML.load_file("subscriptions.yml").freeze

# The fields that heroku sends us
HEROKU_DATA = %w(app git_log head head_long prev_head url user)

configure do
  enable :logging, :dump_errors, :raise_errors
end

get '*' do
  status 405 # Method Not Allowed. Only POST me!
  headers "Allow" => "POST"
end

# default. will use with github, since it's already set-up to use that url
post '/' do
  begin
    if request['payload'] then # Looks like Github. Payload is JSON. Parse and send some mail.
      payload = JSON.parse(request['payload'])
      
      @repo_name       = payload['repository']['name']
      @pusher          = payload['pusher']
      @commits         = payload['commits']
      @sha1            = payload['after']
      @compare_url     = payload['compare']
      @need_to_bundle  = ! @commits.collect{|c| c['modified']}.flatten.uniq.select{|f| /Gemfile(\.lock)?/ =~ f }.empty?
      @need_to_migrate = ! @commits.collect{|c| c['modified']}.flatten.uniq.select{|f| %r[db/schema.rb|db/migrations/.+.rb] =~ f }.empty
      @forced          = payload['forced']
      @ref             = payload['ref']
      @pushed_at       = payload['repository']['pushed_at']
      
      # Send some email
      SUBSCRIPTIONS[-1,1].each do |sub|
        Email.new :subject => "Github Push Update", :body => liquid(:github)
      end
    else # dunno who this is, but the seem to want to give us something. Let's take it!
      request.body.rewind
      File.open(File.join("tmp","#{Time.now.strftime("%Y%m%d-%H%M%S%L")}.file"), "w") do |f| 
        f.puts request.body.read
      end 
      # Send myself an email
    end
  rescue
    # Log the error!
  ensure  
    status 204 # No Content. Server fullfilled request and has nothing further to give you. Now, go away.
  end
end

post '/heroku' do
  @data = request.POST
  status 204 # No Content. Server fullfilled request and has nothing further to give you. Now, go away
end

__END__

@@ github
{{ @repo_name }} has just received a push by {{ @pusher }}.
{% if @need_to_bundle %}You'll want to `bundle install`. {% endif %}
{% if @need_to_migrate %}You'll want to migrate your database. {% endif %}
