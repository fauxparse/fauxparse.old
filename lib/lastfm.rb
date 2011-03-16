module LastFm
  CACHE_KEY_TRACKS = "latest_tracks"
  CACHE_TTL_TRACKS = 180
  CACHE_KEY_ALBUMS = "favourite_albums"
  CACHE_TTL_ALBUMS = 1.day
  CACHE_KEY_COMBINED = "lastfm"

  class Track
    attr_accessor :title, :artist, :album, :image
    
    def initialize(json)
      @title = json["name"]
      @artist = json["artist"]["#text"]
      @album = json["album"]["#text"]
      @image = json["image"].last["#text"]
    end

    def self.latest
      Time.zone = "Auckland"
      json = JSON.parse(open("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=fauxparse&api_key=#{ENV['LASTFM_KEY']}&limit=20&format=json").read)
      json["recenttracks"]["track"].map { |track| new track }
    end
  end
  
  class Album
    attr_accessor :artist, :album, :image
    
    def initialize(json)
      @artist = json["artist"]["name"]
      @album = json["name"]
      @image = json["image"].last["#text"]
    end

    def self.favourites
      Time.zone = "Auckland"
      json = JSON.parse(open("http://ws.audioscrobbler.com/2.0/?method=user.gettopalbums&user=fauxparse&api_key=#{ENV['LASTFM_KEY']}&limit=10&format=json").read)
      json["topalbums"]["album"].map { |album| new album }
    end
    
  end

  def self.stats
    REDIS.get CACHE_KEY_COMBINED or begin
      stats = {}
      stats["tracks"] = if (latest = REDIS.get CACHE_KEY_TRACKS)
        JSON.parse(latest)[0,1]
      else
        Track.latest.tap do |latest|
          REDIS.setex CACHE_KEY_TRACKS, CACHE_TTL_TRACKS, latest.to_json
        end
      end
      stats["albums"] = if (albums = REDIS.get CACHE_KEY_ALBUMS)
        JSON.parse(albums)
      else
        Album.favourites.tap do |albums|
          REDIS.setex CACHE_KEY_ALBUMS, CACHE_TTL_ALBUMS, albums.to_json
        end
      end
      stats.to_json.tap do |json|
        REDIS.setex CACHE_KEY_COMBINED, CACHE_TTL_TRACKS, json
      end
    end
  end

  def self.latest
    REDIS.get CACHE_KEY_TRACKS or Track.latest.to_json.tap do |latest|
      REDIS.setex CACHE_KEY_TRACKS, CACHE_TTL_TRACKS, latest
    end
  end
  
  def self.albums
    REDIS.get CACHE_KEY_ALBUMS or Track.latest.to_json.tap do |latest|
      REDIS.setex CACHE_KEY_ALBUMS, CACHE_TTL_ALBUMS, latest
    end
  end

end