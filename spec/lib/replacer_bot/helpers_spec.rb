module ReplacerBot
  STRINGS = [
    'Open Data',
    'Taylor Swift',
    'Open Data',
    'Something about open data http://foo.com/123',
    'Something about open data http://foo.com/987',
    'Words blah https://some.url/thing more words',
    'Words blah https://some.url/other more words',
    'Words blah https://some.url/thing different words'
  ]

  OTHER_STRINGS = [
    'Something about open data http://foo.com/987',
    'Words blah https://some.url/thing more words',
    'Words blah https://some.url/derp more words',
    'Words blah https://some.url/thing different words',
    'Some new thing',
    'Another new thing with a https://bar.foo',
    'Another new thing with a http://foo.bar'
  ]

  class Dummy
    attr_accessor :id, :text
    @@count = 0
    def initialize text
      @text = text
      @id = @@count += 1
    end

    def self.reset
      @@count = 0
    end
  end

  describe 'Helpers' do
    context 'URLs' do
      it 'URL-encodes a search term' do
        expect(ReplacerBot.encode 'open data').to eq '%22open%20data%22'
      end

      it 'strips out URLs' do
        expect(ReplacerBot.sanitise 'Some string with a https://foo/bar/?baz embedded in it').
          to eq 'Some string with a URL embedded in it'
      end
    end

    context 'uniqing' do
      Dummy.reset

      samples = []
      STRINGS.each do |s|
        samples.push Dummy.new(s)
      end

      let(:list) {samples}
      it 'uniqs on matching text' do
        expect(ReplacerBot.uniq(list)).to be_a Set
        expect(ReplacerBot.uniq(list).map { |l| l.id }).to eq [1, 2, 4, 6, 8]
      end
    end

    context 'filtering' do
      it 'validates liberally' do
        expect(ReplacerBot.validate 'opendata hulk', 'open data').to eq true
      end

      it 'validates more strictly' do
        expect(ReplacerBot.validate 'open data ftw', 'open data', ignore_spaces = false).to eq true
        expect(ReplacerBot.validate 'i love opendata', 'open data', ignore_spaces = false).to eq false
      end

      it 'validates away rubbish' do
        expect(ReplacerBot.validate 'incredible hulk', 'open data').to eq false
      end

      it 'filters retweets' do
        expect(ReplacerBot.validate 'RT @xyz This is about Open Data').to eq false
      end
      it 'filters direct replies' do
        expect(ReplacerBot.validate '@abc This is a reply about Open Data').to eq false
      end

      it 'filters a list' do
        Dummy.reset

        samples = []
        STRINGS.each do |s|
          samples.push Dummy.new(s)
        end

        expect(ReplacerBot.filter(samples).count).to eq 4
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
        expect(ReplacerBot.replace 'Something about Open Data goes here').to eq 'Something about Taylor Swift goes here'
        expect(ReplacerBot.replace 'Something about #opendata http://foo.bar/').to eq 'Something about #TaylorSwift http://foo.bar/'
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
        expect(ReplacerBot.replace 'This is an Open Data tweet').to eq 'This is a Taylor Swift tweet'
        expect(ReplacerBot.replace 'This is an Open Data tweet about an #opendata story').to eq 'This is a Taylor Swift tweet about a #TaylorSwift story'
      end
    end

    context 'find the difference of sets' do
      Dummy.reset

      set_a = []
      STRINGS.each do |s|
        set_a.push s
      end

      set_b = []
      OTHER_STRINGS.each do |s|
        set_b.push Dummy.new(s)
      end

      it 'subtracts one set from another' do
        expect(ReplacerBot.subtract(set_a, set_b).map { |i| i.id }).to eq [5, 6]
      end

      it 'adds one set to another' do
        expect(ReplacerBot.combine(set_a, set_b).count).to eq 9
      end
    end
  end
end
