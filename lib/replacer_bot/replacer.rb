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
        results = ReplacerBot.filter list: @client.search(ReplacerBot.encode(term: @search_term), lang: @config.language, result_type: 'recent').take(@config.search_count), ignore_spaces: @config.ignore_spaces
      end
    end

    def tweets
      search.map { |r| ReplacerBot.truncate ReplacerBot.title_case ReplacerBot.encode_entities ReplacerBot.replace string: r.text }
    end

    def tweet dry_run: false, chatty: false
      tweets.each_with_index do |tweet, index|
        puts "Tweeting: #{tweet}" if chatty
        @client.update tweet unless dry_run
        unless dry_run
        #  unless index == tweets.count - 1
            puts "Sleeping #{@config.interval} seconds" if chatty
            sleep @config.interval
        #  end
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
