#!/usr/bin/env rackup
require 'rubygems'
require 'sinatra'

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production,
  :raise_errors => true
)

# Set up the log file
log = File.new('sinatra.log', 'a')
STDOUT.reopen(log)
STDERR.reopen(log)

require "./app"
run Sinatra::Application
