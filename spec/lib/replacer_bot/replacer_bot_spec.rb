module ReplacerBot
  describe Replacer do
    context 'search' do
      let(:replacer) { described_class.new }

      it 'searches for tweets', :vcr do
        replacer.search
        expect(replacer.results.class).to eq Set
      end

      it 'finds tweets', :vcr do
        replacer.search
        expect(replacer.results.first.class).to eq Twitter::Tweet
      end

      it 'finds the correct tweets', :vcr do
        replacer.search
        expect(replacer.results.first.text).to match /open ?data/i
        expect(replacer.results.all? { |tweet| tweet.text.match /open ?data/i }).to eq true
      end

      it 'uniqs its tweets', :vcr do
        replacer.search
        expect(replacer.search.count).to eq 1
      end

      it 'saves the text of its tweets', :vcr do
        outpath = 'tmp/saved.tweets'
        replacer.config['save_file'] = outpath
        replacer.search
        replacer.save

        expect(File).to exist outpath

        tweets = Marshal.load File.read outpath
        expect(tweets.count).to eq 1
        FileUtils.rm outpath
      end
    end


    context 'only find new tweets' do
      FileUtils.cp 'spec/fixtures/saved.tweets', 'saved.tweets'
      let(:replacer) { described_class.new }

      it 'finds new tweets', :vcr do
        outpath = 'saved.tweets'
        replacer.config['save_file'] = outpath
        replacer.search
        expect(replacer.results.count).to eq 1

        expect(File).to exist outpath

        tweets = Marshal.load File.read outpath
        expect(tweets.count).to eq 17

        FileUtils.rm outpath
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
