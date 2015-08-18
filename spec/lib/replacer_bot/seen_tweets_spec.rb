module ReplacerBot
  describe SeenTweets do
    after :each do
      FileUtils.rm_f Config.instance.config.seen_tweets
    end

    it 'sanitises tweets' do
      expect(described_class.sanitise '#Hashtag at the start with http://derp.com/thing #this and also #these').
        to eq 'at the start with __URL__ #this and also'
    end

    it 'validates the first tweet' do
      expect(described_class.validate 'This is a tweet').to eq true
    end

    it 'invalidates on seeing the same tweet again' do
      described_class.validate 'This is a tweet'
      expect(described_class.validate 'This is a tweet').to eq false
    end

    it 'invalidates similar tweets with different URLs' do
      described_class.validate 'This is a tweet with https://foo.bar/abcd'
      expect(described_class.validate 'This is a tweet with https://foo.bar/xyz').to be false
    end

    it 'invalidates similar tweets laden with hashtags' do
      described_class.validate 'This is a tweet'
      expect(described_class.validate 'This is a tweet #loaded #with #hashtags').to be false
    end

    it 'validates and invalidates correctly' do
      corpus = [
        'This is a tweet with #hashtag https://derp.com/abc #trailing #tags',
        'This is a different tweet',
        '#Needless #hashtags tacked on to #this tweet'
      ]
      corpus.each do |tweet|
        described_class.validate tweet
      end

      test_cases = {
        'This one should be fine' => true,
        'This is a different tweet #with #hashtags' => false,
        '#Different #tags tacked on to #this tweet #here' => false,
        'This is a tweet with #hashtag http://what.even/' => false,
        'This is a tweet with #hashtag http://what.even/xyz #derp' => false
      }
      test_cases.each_pair do |tweet, expectation|
        expect(described_class.validate tweet).to eq expectation
      end

      expect(described_class.retrieve.to_a.sort).to eq [
        "This is a different tweet",
        "This is a tweet with #hashtag __URL__",
        "This one should be fine",
        "tacked on to #this tweet"
      ]
    end

    it 'saves a set' do
      set = Set.new [1, 2, 3]
      described_class.save set

      expect(Marshal.load File.open Config.instance.config.seen_tweets).to be_a Set
      expect(Marshal.load File.open Config.instance.config.seen_tweets).to include 1
      expect(Marshal.load File.open Config.instance.config.seen_tweets).to include 3
    end
  end
end
