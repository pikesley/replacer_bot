module ReplacerBot
  class SeenTweets
    def self.validate tweet
      archive = retrieve
      t = sanitise tweet
      valid = not(archive.include? t) && not(similar_to_archive tweet, archive)
      archive.add t
      save archive

      valid
    end

    def self.similar_to_archive tweet, archive
      match = false

      archive.each do |archived_tweet|
        match = true if similar(tweet, archived_tweet)
      end

      match
    end

    def self.similar tweet, other_tweet, weighting: Config.instance.config.similarity_weighting
      tweet_words = tweet.split ' '
      return false if tweet_words.count < weighting

      match = false

      (tweet_words.count - (weighting - 1)).times do |i|
        sample = tweet_words[i, weighting].join(' ').downcase
        match = true if sanitise(other_tweet.downcase).index sanitise(sample)
      end

      match
    end

    def self.retrieve
      begin
        Marshal.load File.open Config.instance.config.seen_tweets
      rescue Errno::ENOENT
        Set.new
      end
    end

    def self.clean_urls string
      string.gsub /https?:\/\/[^ ]*/, '__URL__'
    end

    def self.hashtag_nuker string:, other_end: false
      words = string.split ' '
      words.reverse! if other_end

      no_hashtag_yet = false

      a = []
      words.each do |token|
        unless ReplacerBot.is_hashtag token
          no_hashtag_yet = true
        end

        if no_hashtag_yet
          a.push token
        end
      end

      a.reverse! if other_end
      a.join ' '
    end

    def self.nuke_hashtags string
      hashtag_nuker string: (hashtag_nuker string: string, other_end: true)
    end

    def self.sanitise tweet
      nuke_hashtags clean_urls tweet
    end

    def self.save set
      File.open Config.instance.config.seen_tweets, 'w' do |file|
        Marshal.dump set, file
      end
    end
  end
end
