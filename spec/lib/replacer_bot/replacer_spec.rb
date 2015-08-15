module ReplacerBot
  describe Replacer do
    context 'search' do
      let(:replacer) { described_class.new }

      it 'searches for tweets', :vcr do
        expect(replacer.search.class).to eq Array
      end

      it 'finds tweets', :vcr do
        expect(replacer.search.first.class).to eq Twitter::Tweet
      end

      it 'finds the correct tweets', :vcr do
        expect(replacer.search.first.text).to match /open ?data/i
        expect(replacer.search.all? { |tweet| tweet.text.match /open ?data/i }).to eq true
      end
    end

    context 'save and retrieve' do
      let(:replacer) { described_class.new }

      it 'saves the ID of the last tweet', :vcr do
        replacer.save
        expect(File).to exist 'last.tweet'

        expect(Marshal.load File.read 'last.tweet').to eq 632586894455500800
        FileUtils.rm 'last.tweet'
      end

      it 'gets a default value for the last tweet', :vcr do
        expect(replacer.last_tweet).to eq 0
      end

      it 'knows the ID of the last tweet', :vcr do
        File.open 'last.tweet', 'w' do |f|
          Marshal.dump 632586894455500800, f
        end
        expect(replacer.last_tweet).to eq 632586894455500800
        FileUtils.rm 'last.tweet'
      end
    end

    context 'only find new tweets', :vcr do
      let(:replacer) { described_class.new }

      it 'finds newer tweets', :vcr do
        File.open 'last.tweet', 'w' do |f|
          Marshal.dump 632591313607589889, f
        end

        expect(replacer.search.count).to eq 2
      end
    end

    context 'tweet' do
      let(:replacer) { described_class.new }

      it 'prepares sensible tweets', :vcr do
        replacer.search
        expect(replacer.tweets).to be_a Array
        expect(replacer.tweets.first).to eq 'Taylor Swift Hackathon 6-7 октября'
        expect(replacer.tweets.all? { |t| t.length <= 140} ).to eq true
      end
    end
  end
end
