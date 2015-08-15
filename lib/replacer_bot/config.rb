module ReplacerBot
  class Config
    include Singleton

    def initialize
      reset!
    end

    def reset! # testing a singleton is hard
      custom = fetch_yaml "#{ENV['HOME']}/.replacer_bot/config.yml"
      defaults = fetch_yaml (File.join(File.dirname(__FILE__), '..', '..', 'config/defaults.yml'))
      defaults.merge! custom

      @config = OpenStruct.new defaults
    end

    def config
      @config
    end

    private

    def fetch_yaml file
      begin
        YAML.load File.open file
      rescue
        {}
      end
    end
  end
end
