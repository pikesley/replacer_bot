module ReplacerBot
  describe Replacer do
    before :all do
      FileUtils.rm_f 'last.tweet'
    end

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

    context 'save last tweet' do
      let(:replacer) { described_class.new }

      it 'saves the ID of the last tweet', :vcr do
        replacer.save
        expect(File).to exist 'last.tweet'

        expect(Marshal.load File.read 'last.tweet').to eq 632605951594524672
        FileUtils.rm 'last.tweet'
      end

      it 'only saves if there is something to save', :vcr do
        File.open 'last.tweet', 'w' do |f|
          Marshal.dump 732591313607589889, f
        end

        replacer.save

        expect(Marshal.load File.read 'last.tweet').to eq 732591313607589889
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
        FileUtils.rm 'last.tweet'
      end
    end

    context 'tweet' do
      let(:replacer) { described_class.new }

      it 'prepares sensible tweets', :vcr do
        expect(replacer.tweets).to be_a Array
        expect(replacer.tweets.first).to eq 'Taylor Swift Hackathon 6-7 октября'
        expect(replacer.tweets.all? { |t| t.length <= 140} ).to eq true
      end
    end
  end
end
