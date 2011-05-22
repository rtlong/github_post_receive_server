#!/usr/bin/env rackup
  require 'rubygems'
  require File.dirname(__FILE__) + '/lib/github_post_receive_server'

use Rack::CommonLogger
use Rack::Lint
run GithubPostReceiveServer::RackApp.new
