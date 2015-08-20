module ReplacerBot
  class Tweet
    attr_reader :text, :id, :user

    def initialize data
      @text = data.text
      @id = data.id
      @user = data.user
    end
  end
end
