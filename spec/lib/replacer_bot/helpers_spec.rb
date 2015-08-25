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
          o = OpenStruct.new
          o.id = 632586894455500800
          Marshal.dump o, f
        end
        expect(ReplacerBot.last_tweet).to eq 632586894455500800
        FileUtils.rm 'last.tweet'
      end
    end

    context 'sanitise' do
      it 'blanks out URLs' do
        expect(ReplacerBot.clean_urls 'Some text with http://foo.bar/ in it').to eq 'Some text with __URL__ in it'
        expect(ReplacerBot.clean_urls 'Other text with https://foo.bar/?123 and http://example.com/derp#fragment in it').to eq 'Other text with __URL__ and __URL__ in it'
        expect(ReplacerBot.clean_urls 'Some text without any URLs in it').to eq 'Some text without any URLs in it'
      end

      it 'removes hashtags from the end of text' do
        expect(ReplacerBot.nuke_hashtags 'Text finishing with a #hashtag').to eq 'Text finishing with a'
        expect(ReplacerBot.nuke_hashtags 'This embedded #hashtag should survive but not this one #spurious').
        to eq 'This embedded #hashtag should survive but not this one'
      end

      it 'removes hashtags from the beginning of text' do
        expect(ReplacerBot.nuke_hashtags '#Beginning hashtag should go away').to eq 'hashtag should go away'
      end

      it 'strips hashtags at either end but leaves embedded ones' do
        expect(ReplacerBot.nuke_hashtags '#This #will go away #but then #also #these').
          to eq 'go away #but then'
      end

      it 'returns nothing if all it gets is hashtags' do
        expect(ReplacerBot.nuke_hashtags '#nothing #but #hashtags').to eq ''
      end

      it 'sanitises tweets' do
        expect(ReplacerBot.sanitise '#Hashtag at the start with http://derp.com/thing #this and also #these').
          to eq 'at the start with __URL__ #this and also'
      end
    end

    context 'filtering' do
      it 'recognises retweets' do
        expect(ReplacerBot.is_retweet 'RT this is a retweet').to eq true
        expect(ReplacerBot.is_retweet 'This is just a tweet').to eq false
      end

      it 'recognises direct replies' do
        expect(ReplacerBot.is_reply '@derp hello').to eq true
        expect(ReplacerBot.is_reply 'Just a tweet').to eq false
      end

      it 'knows if the string contains the search term' do
        expect(ReplacerBot.contains_term 'opendata hulk', 'open data').to eq true
        expect(ReplacerBot.contains_term 'open data ftw', 'open data', ignore_spaces: false).to eq true
        expect(ReplacerBot.contains_term 'i love opendata', 'open data', ignore_spaces: false).to eq false
      end

      it 'rejects over-long tweets' do
        expect(ReplacerBot.too_long 'This one is fine').to eq false
        expect(ReplacerBot.too_long 'This tweet goes over 140 characters abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz').
          to eq true
      end

      it 'validates liberally' do
        expect(ReplacerBot.validate 'opendata hulk', term: 'open data').to eq true
      end

      it 'validates more strictly' do
        expect(ReplacerBot.validate 'open data ftw', term: 'open data', ignore_spaces: false).to eq true
        expect(ReplacerBot.validate 'i love opendata', term: 'open data', ignore_spaces: false).to eq false
      end

      it 'validates away rubbish' do
        expect(ReplacerBot.validate 'incredible hulk', term: 'open data').to eq false
      end

      it 'filters retweets' do
        expect(ReplacerBot.validate 'RT @xyz This is about Open Data').to eq false
      end
      it 'filters direct replies' do
        expect(ReplacerBot.validate '@abc This is a reply about Open Data').to eq false
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

      it 'trims to 140 characters nicely' do
        expect(ReplacerBot.truncate 'FYI via @DBMph: The 2016 proposed budget is now in Taylor Swift format! You may access it on our website: http://t.co/EO6Lep3PeW #Transparency').
          to eq 'FYI via @DBMph: The 2016 proposed budget is now in Taylor Swift format! You may access it on our website: http://t.co/EO6Lep3PeW'
      end

      it 'replaces text' do
        expect(ReplacerBot.replace string: 'Something about Open Data goes here').to eq 'Something about Taylor Swift goes here'
        expect(ReplacerBot.replace string: 'Something about #opendata http://foo.bar/').to eq 'Something about #TaylorSwift http://foo.bar/'
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

      it 'does a full replace' do
        expect(ReplacerBot.replacify 'How #OpenData Can Help Save Lives http://t.co/lkCrPdb8nn by @EllieRoss102 via @guardian').
          to eq 'How #TaylorSwift Can Help Save Lives http://t.co/lkCrPdb8nn by @EllieRoss102 via @guardian'
      end

      it 'uses the correct article in replacements' do
        expect(ReplacerBot.replace string: 'This is an Open Data tweet').to eq 'This is a Taylor Swift tweet'
        expect(ReplacerBot.replace string: 'This is an Open Data tweet about an #opendata story').to eq 'This is a Taylor Swift tweet about a #TaylorSwift story'
      end
    end
  end
end
