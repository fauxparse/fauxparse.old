require "rubygems"
require "bundler"

Bundler.require

require "active_support/core_ext"
require './fauxparse'
run Sinatra::Application
