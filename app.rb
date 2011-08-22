# -*- coding: utf-8 -*-
#!/usr/bin/env ruby
require 'rubygems'
require 'rack'
require 'sinatra'
require 'json'
require 'erubis'
require 'yaml'
require 'active_support/core_ext'
require './email'

Tilt.register :erb, Tilt[:erubis]

# load the file that tells the app who to email
SUBSCRIPTIONS = YAML.load_file("subscriptions.yml").freeze
MAILINGS = SUBSCRIPTIONS["mailings"]

# The fields that heroku sends us
HEROKU_DATA = %w(app git_log head head_long prev_head url user).sort.freeze

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
      @payload = JSON.parse(request['payload'])
      
      owner, repo = @payload['repository'].values_at('owner', 'name')
      @repo = [owner['name'], repo].join('/')
      @branch = @payload['ref'].gsub('refs/heads/', '')
      mods = @payload['commits'].collect{|c| c['modified']}.flatten.uniq
      @suggestions = []
      @suggestions << "`bundle install`" unless mods.select{|f| /Gemfile(\.lock)?/ =~ f }.empty?
      @suggestions << "migrate your database" unless mods.select{|f| %r[db/schema.rb|db/migrations/.+.rb] =~ f }.empty?     
      
      # Send some email
      e = Email.new :subject => "[GitHub] Push to #{@repo}"
      MAILINGS.each do |label, mailing|
        if /#{mailing['repo']}/.match(@repo) then
          e.send mailing['email'], :body => render_email_body(:github, mailing)
        end
      end
      
    else # dunno who this is, but the seem to want to give us something. Let's take it!
      request.body.rewind
      @filename = File.join("tmp","#{Time.now.strftime("%Y%m%d-%H%M%S%L")}.file")
      File.open(@filename, "w") do |f| 
        f.puts request.body.read
      end 
      
      # Send myself an email
      e = Email.new :subject => "post_receive_server - New unknown request"
      e.send MAILINGS['ryan']['email'], :body => render_email_body(:unknown) 

    end
  rescue JSON::ParserError => exception
    # Email about the error!
    e = Email.new :subject => "post_receive_server -- Error", :body => "#{exception.message}\n\n#{request.to_yaml}"
    e.send MAILINGS['ryan']['email']
    
  ensure    
    body nil
    status 204 # No Content. Server fullfilled request and has nothing further to give you. Now, go away.
  end
end

post '/heroku' do
  if params.keys.sort == HEROKU_DATA then # looks like Heroku, go with it.
    params.each_pair do |key, value|
      instance_variable_set "@#{key}", value
    end

    e = Email.new :subject => "[Heroku] #{@app} deployed"
    MAILINGS.each do |label, mailing| 
      if /#{mailing['repo']}/.match(@app) then
        e.send mailing['email'], :body => render_email_body(:heroku, mailing)
      end
    end
  end
  body nil
  status 204 # No Content. Server fullfilled request and has nothing further to give you. Now, go away
end

def render_email_body(template, opts={})
  format = opts['format'] ||= 'email' 
  
  return erb( "#{template.to_s}.#{format}".to_sym )
end

class String
  # Returns an indented string, all lines of string will be indented with count of chars
  def indent(count)
    char = ' '
    (char * count) + gsub(/(\n+)/) { $1 + (char * count) }
  end
end
