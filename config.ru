#!/usr/bin/env rackup
require 'rubygems'
require 'rack'
require 'json'
require 'net/smtp'

def send_email(to,opts={})
  opts[:server]      ||= 'localhost'
  opts[:from]        ||= 'email@example.com'
  opts[:from_alias]  ||= 'Example Emailer'
  opts[:subject]     ||= "You need to see this"
  opts[:body]        ||= "Important stuff!"

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

class Server 
  GO_AWAY_COMMENT = "Be gone, foul creature of the internet."
  THANK_YOU_COMMENT = "Thanks! You beautiful soul you."

  # This is what you get if you make a request that isn't a POST with a
  # payload parameter.
  def rude_comment
    @res.write GO_AWAY_COMMENT
  end

  # Does what it says on the tin. By default, not much, it just prints the
  # received payload.
  def handle_request
    payload = @req.POST["payload"]

    return rude_comment if payload.nil?

    puts payload unless $TESTING # remove me!

    begin 
      payload = JSON.parse(payload).to_yaml
      
    ensure
      send_email "ryan@rtlong.com", :body => payload, :subject => "Github Post Receive Report"
    end
    @res.write THANK_YOU_COMMENT
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