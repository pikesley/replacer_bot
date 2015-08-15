require 'replacer_bot'

module ReplacerBot
  class CLI < Thor
    desc 'version', 'Print replacer version'
    def version
      puts "replacer version #{VERSION}"
    end
    map %w(-v --version) => :version

    desc 'tweet', 'find, munge and send tweets'
    def tweet
      r = Replacer.new
      r.tweet
    end
  end
end
