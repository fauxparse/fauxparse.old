module Photos
  INSTAGRAM_USER_ID = 692502
  CACHE_KEY = "latest_photos"
  CACHE_TTL = 3600
  
  class Photo
    def self.latest
      Instagram::by_user(INSTAGRAM_USER_ID).map do |photo|
        photo.doc.data
      end
    end
  end
  
  def self.latest
    REDIS.get CACHE_KEY or Photo.latest.to_json.tap do |latest|
      REDIS.setex CACHE_KEY, CACHE_TTL, latest
    end
  end
end
