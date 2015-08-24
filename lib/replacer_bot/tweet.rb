module Twitter
  class Tweet
    def sanitised
      @sanitised ||= ReplacerBot.sanitise text
    end

    def replaced
      @replaced ||= ReplacerBot.replacify text
    end

    def save path: ReplacerBot::Config.instance.config.save_file
      File.open path, 'w' do |f|
        Marshal.dump self, f
      end
    end
  end
end
