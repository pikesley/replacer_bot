module ReplacerBot
  def self.encode term
    URI.encode "\"#{term}\""
  end

  def self.last_tweet
    begin
      Marshal.load File.read Config.instance.config.save_file
    rescue ArgumentError
      0
    rescue Errno::ENOENT
      0
    end
  end

  def self.validate string, term = Config.instance.config.search_term, ignore_spaces = true
    return false if string[0...2] == 'RT'
    return false if string[0] == '@'

    term = term.gsub ' ', ' ?' if ignore_spaces
    return true if string.index /#{term}/i

    false
  end

  def self.filter list
    list.select { |i| self.validate i.text, Config.instance.config.search_term }.
      select { |i| i.id > self.last_tweet}
  end

  def self.dehash word
    if word[0] == '#'
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

  def self.replacement_extender replacement
    [
      replacement.map { |k, v| {"#{self.article k} #{k}" => "#{self.article v} #{v}"} }[0],
      replacement.map { |k, v| {"#{self.article k} ##{k}" => "#{self.article v} ##{v}"} }[0]
    ]
  end

  def self.replace string, subs = Config.instance.config.replacements
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
end
