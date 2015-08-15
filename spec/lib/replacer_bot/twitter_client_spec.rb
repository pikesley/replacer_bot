module ReplacerBot
  describe TwitterClient do
    it 'is a twitter client', :vcr do
      expect(described_class.client.class).to eq ::Twitter::REST::Client
    end
  end
end
