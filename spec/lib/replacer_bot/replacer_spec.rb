module ReplacerBot
  describe Replacer do
    context 'search' do
      let(:replacer) { described_class.new }

      it 'searches for tweets', :vcr do
      #  replacer.search
        expect(replacer.search.class).to eq Array
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
    end


    context 'only find new tweets' do
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
