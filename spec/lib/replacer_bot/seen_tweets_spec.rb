module ReplacerBot
  describe SeenTweets do
    after :each do
      FileUtils.rm_f Config.instance.config.seen_tweets
    end

    let :r do
      r = ReplacerBot::Searcher.results
    #  require 'pry' ; binding.pry
      r.sort { |s, t| s.text <=> t.text }.each_with_index { |t, i| puts "#{i} -- #{t.text}" }

      r
    end

    it 'validates the first tweet', :vcr do
      expect(described_class.validate r.first).to eq true
    end

    it 'invalidates on seeing the same tweet again', :vcr do
      described_class.validate r.first
      expect(described_class.validate r.first).to eq false
    end

  #  it 'invalidates similar tweets with different URLs', :vcr do
  #    described_class.validate r[1]
  #    s = double
  #    s.stub(:text) { r[1].text.gsub /http:[^ ]*/, 'http://fake.url' }
  #    expect(described_class.validate s).to be false
  #  end
#
#    it 'invalidates similar tweets laden with hashtags' do
#      described_class.validate 'This is a tweet'
#      expect(described_class.validate 'This is a tweet #loaded #with #hashtags').to be false
#    end
#
#    it 'validates and invalidates correctly' do
#      corpus = [
#        'This is a tweet with #hashtag https://derp.com/abc #trailing #tags',
#        'This is a different tweet',
#        '#Needless #hashtags tacked on to #this tweet'
#      ]
#      corpus.each do |tweet|
#        described_class.validate tweet
#      end
#
#      test_cases = {
#        'This one should be fine' => true,
#        'This is a different tweet #with #hashtags' => false,
#        '#Different #tags tacked on to #this tweet #here' => false,
#        'This is a tweet with #hashtag http://what.even/' => false,
#        'This is a tweet with #hashtag http://what.even/xyz #derp' => false
#      }
#      test_cases.each_pair do |tweet, expectation|
#        expect(described_class.validate tweet).to eq expectation
#      end
#
#      expect(described_class.retrieve.to_a.sort).to eq [
#        "This is a different tweet",
#        "This is a tweet with #hashtag __URL__",
#        "This one should be fine",
#        "tacked on to #this tweet"
#      ]
#    end
#
#    context 'overlap of words' do
#      # n is set in the default config, a lower value makes the bot less noisy at the risk of false negatives
#      it 'does not match on tweets with fewer than n words' do
#        expect(described_class.similar 'appears to match', 'You would think this appears to match').to eq false
#      end
#
#      it 'sees tweets which overlap by at least n words as similar' do
#        expect(described_class.similar 'This is a string of words', 'Also this is a string of words innit').to eq true
#        expect(described_class.similar 'This is a string of words', 'Also this is a similar string similar words innit').to eq false
#        expect(described_class.similar 'This one will be a definite match ', 'So this one will be a definite match no doubt').to eq true
#      end
#
#      it 'deals sensibly with URLs and hashtags' do
#        expect(described_class.similar 'This one has a http://taylor.swift in it', 'So this one has a http://other.url/ in it here').to eq true
#      end
#
#      it 'works on real-world data' do
#        expect(described_class.
#        similar 'Netflix Releases Taylor Swift-Fetching Developer Preview: Netflix has released a developer preview of its in-house… bit.ly/1JfRdgA',
#          'Netflix Releases Taylor Swift-Fetching Developer Preview - Netflix has released a developer preview of its in-house d...'
#        ).to eq true
#      end
#    end
#
#    it 'saves a set' do
#      set = Set.new [1, 2, 3]
#      described_class.save set
#
#      expect(Marshal.load File.open Config.instance.config.seen_tweets).to be_a Set
#      expect(Marshal.load File.open Config.instance.config.seen_tweets).to include 1
#      expect(Marshal.load File.open Config.instance.config.seen_tweets).to include 3
#    end
  end
end
