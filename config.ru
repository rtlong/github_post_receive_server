#!/usr/bin/env rackup
require 'rubygems'
require 'sinatra'

# Set up the log file
log = File.new('sinatra.log', 'a')
STDOUT.reopen(log)
STDOUT.sync = true
STDERR.reopen(log)
STDERR.sync = true

# Load the app
require "./app"
run Sinatra::Application
