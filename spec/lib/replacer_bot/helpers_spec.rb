module ReplacerBot
  describe 'Helpers' do
    after :each do
      FileUtils.rm_f Config.instance.config.save_file
      FileUtils.rm_f Config.instance.config.seen_tweets
    end

    it 'recognises a hashtag' do
      expect(ReplacerBot.is_hashtag '#hashtag').to eq true
      expect(ReplacerBot.is_hashtag 'not_hashtag').to eq false
    end

    it 'encodes HTML entities' do
      expect(ReplacerBot.encode_entities 'This has a &amp; in it').to eq 'This has a & in it'
      expect(ReplacerBot.encode_entities 'This has no entities that need coding & ting').
        to eq 'This has no entities that need coding & ting'
    end

    context 'URLs' do
      it 'URL-encodes a search term' do
        expect(ReplacerBot.encode term: 'open data').to eq '%22open%20data%22'
      end
    end

    context 'last tweet' do
      it 'gets a default value for the last tweet' do
        expect(ReplacerBot.last_tweet).to eq 0
      end

      it 'knows the ID of the last tweet' do
        File.open 'last.tweet', 'w' do |f|
          Marshal.dump 632586894455500800, f
        end
        expect(ReplacerBot.last_tweet).to eq 632586894455500800
        FileUtils.rm 'last.tweet'
      end
    end

    context 'filtering' do
      it 'validates liberally' do
        expect(ReplacerBot.validate string: 'opendata hulk', term: 'open data').to eq true
      end

      it 'validates more strictly' do
        expect(ReplacerBot.validate string: 'open data ftw', term: 'open data', ignore_spaces: false).to eq true
        expect(ReplacerBot.validate string: 'i love opendata', term: 'open data', ignore_spaces: false).to eq false
      end

      it 'validates away rubbish' do
        expect(ReplacerBot.validate string: 'incredible hulk', term: 'open data').to eq false
      end

      it 'filters retweets' do
        expect(ReplacerBot.validate string: 'RT @xyz This is about Open Data').to eq false
      end

      it 'filters direct replies' do
        expect(ReplacerBot.validate string: '@abc This is a reply about Open Data').to eq false
      end

      it 'knows what a Complex Search is' do
        expect(ReplacerBot.complex_search string: 'this OR that').to eq true
        expect(ReplacerBot.complex_search string: 'this AND that').to eq true
        expect(ReplacerBot.complex_search string: 'this, that').to eq false
      end
    end

    context 'search and replace' do
      it 'removes a hash from the start of a word' do
        expect(ReplacerBot.dehash '#opendata').to eq 'opendata'
        expect(ReplacerBot.dehash 'data').to eq 'data'
      end

      it 'squashes whitespace' do
        expect(ReplacerBot.despace 'open  data').to eq 'open data'
        expect(ReplacerBot.despace 'open    data  taylor    swift').to eq 'open data taylor swift'
        expect(ReplacerBot.despace " open\n\ndata  ").to eq 'open data'
      end

      it 'upcases the first character' do
        expect(ReplacerBot.title_case 'lowercase at the start').to eq 'Lowercase at the start'
      end

      it 'trims to 140 characters nicely' do
        expect(ReplacerBot.truncate 'FYI via @DBMph: The 2016 proposed budget is now in Taylor Swift format! You may access it on our website: http://t.co/EO6Lep3PeW #Transparency').
          to eq 'FYI via @DBMph: The 2016 proposed budget is now in Taylor Swift format! You may access it on our website: http://t.co/EO6Lep3PeW'
      end

      it 'replaces text' do
        expect(ReplacerBot.replace string: 'Something about Open Data goes here').to eq 'Something about Taylor Swift goes here'
        expect(ReplacerBot.replace string: 'Something about #opendata http://foo.bar/').to eq 'Something about #TaylorSwift http://foo.bar/'
        expect(ReplacerBot.replace string: 'OPEN DATA things and an #OpenData hashtag and this OPen DatA').to eq 'TAYLOR SWIFT things and a #TaylorSwift hashtag and this Taylor Swift'
      end

      it 'does a/an correctly' do
        expect(ReplacerBot.article 'Open Data').to eq 'an'
        expect(ReplacerBot.article 'Taylor Swift').to eq 'a'
      end

      it 'extends replacements correctly' do
        expect(ReplacerBot.replacement_extender 'open data' => 'Taylor Swift').
          to eq(
            [
              {'an open data' => 'a Taylor Swift'},
              {'an #open data' => 'a #Taylor Swift'}
            ]
          )
      end

      it 'uses the correct article in replacements' do
        expect(ReplacerBot.replace string: 'This is an Open Data tweet').to eq 'This is a Taylor Swift tweet'
        expect(ReplacerBot.replace string: 'This is an Open Data tweet about an #opendata story').to eq 'This is a Taylor Swift tweet about a #TaylorSwift story'
      end
    end
  end
end
