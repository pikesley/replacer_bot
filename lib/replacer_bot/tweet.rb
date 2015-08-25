module Twitter
  class Tweet
    def sanitised
      @sanitised ||= ReplacerBot.sanitise text
    end

    def replaced
      @replaced ||= ReplacerBot.replacify text
    end

    def valid
      ReplacerBot.validate(text) || ReplacerBot.too_long(replaced) # if Config.instance.config.reject_long_tweets
    end

    def tweet
      ReplacerBot::TwitterClient.instance.client.update replaced
    end

    def save path: ReplacerBot::Config.instance.config.save_file
      File.open path, 'w' do |f|
        Marshal.dump self, f
      end
    end
  end
end
