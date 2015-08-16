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
        results = ReplacerBot.filter @client.search(ReplacerBot.encode(@search_term), result_type: 'recent').take(@config.search_count), @config.ignore_spaces
      end
    end

    def tweets
      search.map { |r| ReplacerBot.truncate ReplacerBot.replace r.text }
    end

    def tweet dry_run = false
      tweets.each_with_index do |tweet, index|
        puts "Tweeting: #{tweet}"
        @client.update tweet unless dry_run
        unless dry_run
          unless index == tweets.count - 1
            puts "Sleeping #{@config.interval} seconds"
            sleep @config.interval
          end
        end
      end

      save unless dry_run
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
