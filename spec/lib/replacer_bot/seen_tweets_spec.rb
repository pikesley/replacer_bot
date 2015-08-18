module ReplacerBot
  describe SeenTweets do
    after :each do
      FileUtils.rm_f Config.instance.config.seen_tweets
    end

    context 'sanitise' do
      it 'blanks out URLs' do
        expect(described_class.clean_urls 'Some text with http://foo.bar/ in it').to eq 'Some text with __URL__ in it'
        expect(described_class.clean_urls 'Other text with https://foo.bar/?123 and http://example.com/derp#fragment in it').to eq 'Other text with __URL__ and __URL__ in it'
        expect(described_class.clean_urls 'Some text without any URLs in it').to eq 'Some text without any URLs in it'
      end

      it 'removes hashtags from the end of text' do
        expect(described_class.nuke_hashtags 'Text finishing with a #hashtag').to eq 'Text finishing with a'
        expect(described_class.nuke_hashtags 'This embedded #hashtag should survive but not this one #spurious').
        to eq 'This embedded #hashtag should survive but not this one'
      end

      it 'removes hashtags from the beginning of text' do
        expect(described_class.nuke_hashtags '#Beginning hashtag should go away').to eq 'hashtag should go away'
      end

      it 'strips hashtags at either end but leaves embedded ones' do
        expect(described_class.nuke_hashtags '#This #will go away #but then #also #these').
          to eq 'go away #but then'
      end

      it 'returns nothing if all it gets is hashtags' do
        expect(described_class.nuke_hashtags '#nothing #but #hashtags').to eq ''
      end

      it 'sanitises tweets' do
        expect(described_class.sanitise '#Hashtag at the start with http://derp.com/thing #this and also #these').
          to eq 'at the start with __URL__ #this and also'
      end
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
