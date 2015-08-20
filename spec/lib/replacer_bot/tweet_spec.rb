module ReplacerBot
  describe Tweet do
    after :each do
      FileUtils.rm_f 'seen.tweets'
    end

    let :t do
      r = Replacer.new
      Tweet.new r.search.first
    end

    it 'has tweet-like stuff', :vcr do
      expect(t.text).to eq '#OpenData will be accepted and not feared! Scotland gives it a push. #DigitalTransformation http://t.co/eyDgDNjDtz'
      expect(t.id).to eq 634432215196135425
      expect(t.user.id).to eq 861512810
    end
  end
end
