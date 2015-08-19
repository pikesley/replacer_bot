module ReplacerBot
  class Replacer
    attr_reader :results, :config, :client

    def initialize
      @config = Config.instance.config
      @search_term = @config.search_term
      @client = TwitterClient.client
    end

    def search #count = 20
      @results ||= begin
        results = ReplacerBot.filter list: @client.search(ReplacerBot.encode(term: @search_term), result_type: 'recent').take(@config.search_count), ignore_spaces: @config.ignore_spaces
      end
    end

    def tweets
      search.map { |r| ReplacerBot.truncate ReplacerBot.encode_entities ReplacerBot.replace string: r.text }
    end

    def tweet dry_run: false, chatty: false
      tweets.each_with_index do |tweet, index|
        send_tweet content: tweet, pause: index != tweets.count - 1, dry_run: dry_run, chatty: chatty
      end

      save unless dry_run
    end

    def send_tweet content:, pause: true, dry_run: false, chatty: false
      puts "Tweeting: #{content}" if chatty
      @client.update content unless dry_run
      unless dry_run
        if pause
          puts "Sleeping #{@config.interval} seconds" if chatty
          sleep @config.interval
        end
      end
    end

    def save
      if search.first

        File.open @config.save_file, 'w' do |file|
          Marshal.dump search.first.id, file
        end
      end
    end
  end
end
