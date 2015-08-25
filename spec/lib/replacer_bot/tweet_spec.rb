module Twitter
  describe Tweet do
    let :t do
      ReplacerBot::Searcher.results.first
    end

    it 'has standard tweet stuff', :vcr do
      expect(t.text).to eq 'RT @ukces: Interested in labour market intelligence, open data, &amp; free careers resources? Follow @LMIforAll to find out more &gt; http://t.co/…'
      expect(t.id).to eq 635821996954251264
      expect(t.user.id).to eq 1967535163
    end

    it 'gets sanitized correctly', :vcr do
      expect(t.sanitised).to eq 'RT @ukces: Interested in labour market intelligence, open data, & free careers resources? Follow @LMIforAll to find out more > __URL__'
    end

    it 'gets search-and-replaced correctly', :vcr do
      expect(t.replaced).to eq 'RT @ukces: Interested in labour market intelligence, Taylor Swift, & free careers resources? Follow @LMIforAll to find out more >'
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
        expect(m.id).to eq 635821996954251264
        expect(m.sanitised).to eq 'RT @ukces: Interested in labour market intelligence, open data, & free careers resources? Follow @LMIforAll to find out more > __URL__'
        expect(m.replaced).to eq 'RT @ukces: Interested in labour market intelligence, Taylor Swift, & free careers resources? Follow @LMIforAll to find out more >'
      end
    end

    context 'validity' do
      let :r do
        r = ReplacerBot::Searcher.results
    #    r.each_with_index { |t, i| puts "#{i}: #{t.text}, #{t.text.length}" }
      end

      it 'knows if it is valid', :vcr do
        expect(r.first.valid).to be true
        expect(r[1].valid).to be false
        expect(r[22].valid).to be false
        expect(r[87].valid).to be false
      end
    end

    it 'tweets itself', :vcr do
    #  expect(ReplacerBot::TwitterClient.instance.client).to(receive(:update))
      t.tweet
    end
  end
end
