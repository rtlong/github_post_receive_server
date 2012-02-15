#!/usr/bin/env rackup
require 'rubygems'
require 'sinatra'
require 'yaml'

# Set up the log file
log = File.new('sinatra.log', 'a')
log.sync = true
STDOUT.reopen(log)
STDERR.reopen(log)

ENV.update YAML.load_file('.env')

# Load the app
require "./app"
run Sinatra::Application
