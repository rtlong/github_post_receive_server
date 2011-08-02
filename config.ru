#!/usr/bin/env rackup
require 'rubygems'
require 'rack'
require 'json'
require 'net/smtp'
require 'yaml'

class Server 
  ERROR_COMMENT = "Invalid data. Need to POST a JSON object in the 'payload'"
  ACCEPT_COMMENT = "OK"

  # This is what you get if you make a request that isn't a POST with a
  # payload parameter.
  def error_comment
    @res.write ERROR_COMMENT
  end
  
  def send_email(to,opts={})
    opts[:server]      ||= 'home.rtlong.com'
    opts[:from]        ||= 'updates@github.home.rtlong.com'
    opts[:from_alias]  ||= 'Github Push Notifier'
    opts[:subject]     ||= "Github Post Receive Report"

    msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{to}>
Subject: #{opts[:subject]}

#{opts[:body]}
END_OF_MESSAGE

    Net::SMTP.start(opts[:server]) do |smtp|
      smtp.send_message msg, opts[:from], to
    end
  end

  def handle_request
    payload = @req.POST["payload"].strip

    return error_comment unless payload && payload.length >= 2 

    @payload = JSON.parse(payload)
    @body = @payload.to_yaml
    
    # if there is a problem, it won't send to the phone
    repo = @payload['repository']['name']
    commits = @payload['commits'].collect{ |c| c['message'] }
    author = @payload['commits'].first['author']['name']
    sms = "Updates to #{repo}: #{author} / #{commits.join(' /// ')}" 
    send_email "ryan.long@tmomail.net", :body => sms
  rescue 
    @body ||= "There was an issue generating this report. Probably, the JSON was invalid:\n\n#{payload}"
  ensure
    send_email "ryan@rtlong.com", :body => @body
    @res.write ACCEPT_COMMENT
  end

  # Call is the entry point for all rack apps.
  def call(env)
    @req = Rack::Request.new(env)
    @res = Rack::Response.new
    handle_request
    @res.finish
  end
end

run Server.new