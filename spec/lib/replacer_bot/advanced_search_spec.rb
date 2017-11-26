module ReplacerBot
  describe Replacer do
    before :each do
      Config.instance.config.search_term = "joe root"
      Config.instance.config.extra_search_terms = [ "ashes", "england" ]
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
        expect(replacer.search.first.text).to match /joe root/i
      #  expect(replacer.search.all? { |tweet| tweet.text.match /(detect|predict)/i }).to eq true
      end
    end

    context 'search helper' do
      it 'matches against extra search terms' do
        Config.instance.config.extra_search_terms = [ "predict", "future" ]
        expect(ReplacerBot.has_extra_terms string: "foo").to eq false
        expect(ReplacerBot.has_extra_terms string: "foo in the future").to eq true
      end

      it 'does the right thing with no extra terms' do
        Config.instance.config.extra_search_terms = nil
        expect(ReplacerBot.has_extra_terms string: "foo").to eq true
      end
    end
  end
end
