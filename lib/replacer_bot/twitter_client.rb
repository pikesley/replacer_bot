module ReplacerBot
  class TwitterClient
    def self.client
      config = {
        consumer_key:        ENV['CONSUMER_KEY'],
        consumer_secret:     ENV['CONSUMER_SECRET'],
        access_token:        ENV['TOKEN'],
        access_token_secret: ENV['SECRET']
      }

      ::Twitter::REST::Client.new(config)
    end
  end
end
