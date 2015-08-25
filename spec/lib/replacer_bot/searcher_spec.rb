module ReplacerBot
  describe Searcher do
    it 'returns something', :vcr do
      expect(described_class.results).to be_an Array
    end

    it 'returns tweets', :vcr do
      expect(described_class.results.first).to be_a Twitter::Tweet
    end

    it 'returns kosher tweets', :vcr do
      expect(described_class.results.first.text).to match /open ?data/i
    end
  end
end
