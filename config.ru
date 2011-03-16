require "rubygems"
require "bundler"

Bundler.require

require './fauxparse'
run Sinatra::Application
