require "open-uri"

module Twitter
  CACHE_KEY = "latest_tweets"
  CACHE_TTL = 300
  
  class Tweet
    attr_accessor :text, :created_at
    
    def initialize(json)
      @text = json["text"]
      @created_at = Time.zone.parse(json["created_at"]).strftime("%A, %d %B, %Y at %I:%M%p").gsub(/(\s)0/, "\\1").sub(/[AP]M$/) { |x| x.downcase }
    end
    
    def self.latest
      Time.zone = "Auckland"
      json = JSON.parse(open("http://twitter.com/statuses/user_timeline/fauxparse.json?count=50").read)
      json.reject { |t|
        t["text"].starts_with? "@"
      }.map { |tweet| new tweet }
    end
  end
  
  def self.latest
    REDIS.get CACHE_KEY or Tweet.latest.to_json.tap do |latest|
      REDIS.setex CACHE_KEY, CACHE_TTL, latest
    end
  end
end