module ReplacerBot
  class SeenTweets
    def self.validate tweet
      archive = retrieve
      t = sanitise tweet
      valid = not(archive.include? t)
      archive.add t
      save archive

      valid
    end

    def self.retrieve
      begin
        Marshal.load File.open Config.instance.config.seen_tweets
      rescue Errno::ENOENT
        Set.new
      end
    end

    def self.sanitise tweet
      ReplacerBot.nuke_hashtags ReplacerBot.clean_urls tweet
    end

    def self.save set
      File.open Config.instance.config.seen_tweets, 'w' do |file|
        Marshal.dump set, file
      end
    end
  end
end
