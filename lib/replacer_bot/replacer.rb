module ReplacerBot
  class Replacer
    attr_reader :results, :config

    def initialize
      @config = Config.instance.config
      @search_term = @config.search_term
      @client = TwitterClient.client
    end

    def search count = 20
      @results ||= begin
        results = @client.search(ReplacerBot.encode(@search_term), result_type: 'recent').take(count)
        ReplacerBot.filter results
      end
    end

    def seen_tweets
      @seen_tweets ||= begin
        Marshal.load File.read @config.save_file
      rescue Errno::ENOENT
        Set.new
      end
    end

    def tweets
      @results.map { |r| ReplacerBot.truncate ReplacerBot.replace r.text }
    end

    def tweet
      tweets.each do |tweet|
        puts "Tweeting: #{tweet}"
        @client.update tweet
        puts "Sleeping #{@config.interval} seconds"
        sleep @config.interval
      end
    end

    def save
      File.open @config.save_file, 'w' do |file|
#        Marshal.dump @all_results, file
        Marshal.dump Set.new(@results.map { |result| result.text }), file
      end
    end
  end
end
