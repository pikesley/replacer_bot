module ReplacerBot
  describe Tweet do
    after :each do
      FileUtils.rm_f 'seen.tweets'
      FileUtils.rm_f 'saved.tweet'
    end

    let :t do
      r = Replacer.new
      Tweet.new r.search.first
    end

    it 'has standard tweet stuff', :vcr do
      expect(t.text).to eq '#OpenData will be accepted and not feared! Scotland gives it a push. #DigitalTransformation http://t.co/eyDgDNjDtz'
      expect(t.id).to eq 634432215196135425
      expect(t.user.id).to eq 861512810
    end

    context 'save' do
      before :each do
        t.save 'saved.tweet'
      end

      after :each do
        FileUtils.rm_f 'saved.tweet'
      end

      it 'saves to file', :vcr do
        expect(File).to exist 'saved.tweet'
      end

      it 'saves the correct stuff', :vcr do
        m = Marshal.load File.read 'saved.tweet'
        expect(m.id).to eq 634432215196135425
      end
    end

    it 'gets sanitized correctly', :vcr do
      expect(t.sanitised).to eq 'will be accepted and not feared! Scotland gives it a push. #DigitalTransformation __URL__'
    end

    context 'search-and-replace' do
      it 'gets mangled correctly', :vcr do
        expect(t.replaced).to eq '#TaylorSwift will be accepted and not feared! Scotland gives it a push. #DigitalTransformation http://t.co/eyDgDNjDtz'

      end
    end
  end
end
