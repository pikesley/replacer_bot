module Twitter
  describe Tweet do
    let :t do
      r = ReplacerBot::Replacer.new.search.first
    end

    it 'has standard tweet stuff', :vcr do
      expect(t.text).to eq 'How #OpenData Can Help Save Lives http://t.co/lkCrPdb8nn by @EllieRoss102 via @guardian'
      expect(t.id).to eq 635821849419517952
      expect(t.user.id).to eq 22164685
    end

    it 'gets sanitized correctly', :vcr do
      expect(t.sanitised).to eq 'How #OpenData Can Help Save Lives __URL__ by @EllieRoss102 via @guardian'
    end

    it 'gets search-and-replaced correctly', :vcr do
      expect(t.replaced).to eq 'How #TaylorSwift Can Help Save Lives http://t.co/lkCrPdb8nn by @EllieRoss102 via @guardian'
    end

    context 'save' do
      after :each do
        FileUtils.rm_f 'last.tweet'
      end

      it 'saves to file', :vcr do
        t.save
        expect(File).to exist 'last.tweet'
      end

      it 'saves the correct stuff', :vcr do
        t.save
        m = Marshal.load File.read 'last.tweet'
        expect(m.id).to eq 635821849419517952
        expect(m.sanitised).to eq 'How #OpenData Can Help Save Lives __URL__ by @EllieRoss102 via @guardian'
        expect(m.replaced).to eq 'How #TaylorSwift Can Help Save Lives http://t.co/lkCrPdb8nn by @EllieRoss102 via @guardian'
      end

      it 'tweets itself', :vcr do
        
      end
    end
  end
end
