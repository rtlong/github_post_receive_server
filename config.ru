#!/usr/bin/env rackup
require "./app"


# Set up the log file
#LOG = File.new('sinatra.log', 'a')
#STDOUT.reopen(LOG)
#STDERR.reopen(LOG)

run Sinatra::Application