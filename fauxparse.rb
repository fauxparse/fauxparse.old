require "erb"
require "./lib/twitter"
require "./lib/lastfm"
require "./lib/photos"

configure do
  REDIS = if config = ENV['REDISTOGO_URL']
    uri = URI.parse(ENV["REDISTOGO_URL"])
    Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  else
    Redis.new
  end
end

get "/" do
  erb :index
end

get "/tweets" do
  content_type :json
  headers['Cache-Control'] = 'max-age=300, must-revalidate'
  Twitter.latest
end

get "/lastfm" do
  content_type :json
  headers['Cache-Control'] = 'max-age=0, must-revalidate'
  LastFm.stats
end

get "/photos" do
  content_type :json
  headers['Cache-Control'] = 'max-age=0, must-revalidate'
  Photos.latest
end
