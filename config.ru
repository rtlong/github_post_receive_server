#!/usr/bin/env rackup
require 'rubygems'
require 'sinatra'

# Set up the log file
log = File.new('sinatra.log', 'a')
log.sync = true
STDOUT.reopen(log)
STDERR.reopen(log)

# Load the app
require "./app"
run Sinatra::Application
