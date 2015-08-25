module ReplacerBot
  class Searcher
    def self.results term: Config.instance.config.search_term, count: Config.instance.config.search_count
      TwitterClient.instance.client.search(ReplacerBot.encode(term: term), result_type: 'recent').take(count)
    end
  end
end
