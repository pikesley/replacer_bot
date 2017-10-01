module ReplacerBot
  describe Replacer do
    before :each do
      Config.instance.config.search_term = "artificial intelligence"
    end

    after :each do
      FileUtils.rm_f Config.instance.config.save_file
      FileUtils.rm_f Config.instance.config.seen_tweets
      Config.instance.reset!
    end

    context 'advanced search' do
      let(:replacer) { described_class.new }

      it 'searches for tweets', :vcr do
        expect(replacer.search.class).to eq Array
      end

      it 'finds tweets', :vcr do
        expect(replacer.search.first.class).to eq Twitter::Tweet
      end

      it 'finds the correct tweets', :vcr do
        expect(replacer.search.first.text).to match /artificial intelligence/i
        expect(replacer.search.all? { |tweet| tweet.text.match /artificial ?intelligence/i }).to eq true
      end

      it 'finds English tweets', :vcr do
        expect(replacer.search.all? { |tweet| tweet.lang == 'en' }).to eq true
      end
    end
  end
end
