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

    desc 'dry_run', "find, munge but don't actually send tweets"
    def dry_run
      r = Replacer.new
      r.tweet dry_run = true
    end
  end
end
