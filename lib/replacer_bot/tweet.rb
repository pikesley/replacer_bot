module ReplacerBot
  class Tweet
    attr_reader :text, :id, :user

    def initialize data
      @text = data.text
      @id = data.id
      @user = data.user
    end

    def sanitised
      @sanitised ||= 
    end

    def replaced
      @replaced ||= ReplacerBot.truncate ReplacerBot.encode_entities ReplacerBot.replace string: @text
    end

    def save path
      File.open path, 'w' do |f|
        Marshal.dump self, f
      end
    end
  end
end
