class String
  def titlecase
    bits = self.split ''
    bits[0] = UnicodeUtils.upcase(bits[0])

    bits.join ''
  end

  def upcase
    UnicodeUtils.upcase self
  end
end

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
      Marshal.load File.read Config.instance.config.save_file
    rescue ArgumentError
      0
    rescue Errno::ENOENT
      0
    end
  end

  def self.validate string:, term: Config.instance.config.search_term, ignore_spaces: true
    return false if string[0...2] == 'RT'
    return false if string[0] == '@'
    return false unless self.has_extra_terms(string: string)

    term = term.gsub ' ', ' ?' if ignore_spaces
    return true if string.index(/#{term}/i) && SeenTweets.validate(string)

    false
  end

  def self.filter list:, ignore_spaces: true
    list.select { |i| self.validate string: i.text, term: Config.instance.config.search_term, ignore_spaces: ignore_spaces }.
      select { |i| i.id > self.last_tweet}
  end

  def self.has_extra_terms string:
    return true unless Config.instance.config.extra_search_terms

    Config.instance.config.extra_search_terms.each do |term|
      return true if string.downcase.index term.downcase
    end

    false
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

  def self.title_case string
    bits = string.split ''
    bits[0] = UnicodeUtils.upcase(bits[0])

    bits.join ''
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

  def self.replacement_caser replacement
    l = []
    l.push({replacement.first[0].upcase => replacement.first[1].upcase})
    l.push({replacement.first[0].downcase => replacement.first[1]})
    l.push({replacement.first[0].titlecase => replacement.first[1].titlecase})

    l.uniq
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
    subs.map { |s| self.replacement_caser(s) }.flatten.each do |substitute|
      (self.replacement_extender(substitute) << substitute).each do |s|
        s.each do |search, replace|
          our_string = self.despace our_string
          our_string.gsub! search, replace
        end
      end
    end

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
