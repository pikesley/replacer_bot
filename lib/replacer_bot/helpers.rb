module ReplacerBot
  def self.encode term:
    URI.encode "\"#{term}\""
  end

  def self.is_hashtag word
    word[0] == '#'
  end

  def self.encode_entities string
    coder = HTMLEntities.new
    coder.decode string
  end

  def self.last_tweet
    begin
      (Marshal.load File.read Config.instance.config.save_file).id
    rescue ArgumentError
      0
    rescue Errno::ENOENT
      0
    end
  end

  def self.is_retweet string
      string.index('RT') == 0
  end

  def self.is_reply string
    string.index('@') == 0
  end

  def self.contains_term string, term, ignore_spaces: true
    term = term.gsub ' ', ' ?' if ignore_spaces
    string.index(/#{term}/i) && true || false
  end

  def self.validate string:, term: Config.instance.config.search_term, ignore_spaces: true
    return false if is_retweet(string)
    return false if is_reply(string)

    return true if contains_term(string, term, ignore_spaces: ignore_spaces)

    false
  end

  def self.filter list:, ignore_spaces: true
    list.select { |i| self.validate string: i.text, term: Config.instance.config.search_term, ignore_spaces: ignore_spaces }.
      select { |i| i.id > self.last_tweet}
  end

  def self.dehash word
    if is_hashtag word
      return word[1..-1]
    end

    word
  end

  def self.despace string
    string.gsub(/\n+/, ' ').gsub(/ +/, ' ').strip
  end

  def self.truncate text
    return_text = ''
    text.split.each do |word|
      new_text = "#{return_text} #{word}".strip
      if new_text.length > TWITTER_LIMIT
        return return_text
      else
        return_text = new_text
      end
    end

    return_text
  end

  def self.article string
    string = self.dehash string
    specials = [ 'hotel' ]

    if specials.include? string.downcase
      return 'an'
    end

    if 'aeiou'.include? string[0].downcase
      return 'an'
    end

    'a'
  end

  def self.clean_urls string
    string.gsub /https?:\/\/[^ ]*/, '__URL__'
  end

  def self.hashtag_nuker string:, other_end: false
    words = string.split ' '
    words.reverse! if other_end

    no_hashtag_yet = false

    a = []
    words.each do |token|
      unless ReplacerBot.is_hashtag token
        no_hashtag_yet = true
      end

      if no_hashtag_yet
        a.push token
      end
    end

    a.reverse! if other_end
    a.join ' '
  end

  def self.nuke_hashtags string
    hashtag_nuker string: (hashtag_nuker string: string, other_end: true)
  end

  def self.sanitise tweet
    nuke_hashtags clean_urls encode_entities tweet
  end

  def self.replacement_extender replacement
    [
      replacement.map { |k, v| {"#{self.article k} #{k}" => "#{self.article v} #{v}"} }[0],
      replacement.map { |k, v| {"#{self.article k} ##{k}" => "#{self.article v} ##{v}"} }[0]
    ]
  end

  def self.replace string:, subs: Config.instance.config.replacements
    # Something about a frozen string
    our_string = string.dup
    subs.each do |substitute|
      (self.replacement_extender(substitute) << substitute).each do |s|
        s.each do |search, replace|
          our_string = self.despace our_string
          our_string.gsub! /#{search}/i, replace
        end
      end
    end

    our_string
  end

  def self.replacify string
    truncate encode_entities replace string: string
  end
end
