module ReplacerBot
  describe Replacer do
    after :each do
      FileUtils.rm_f Config.instance.config.save_file
      FileUtils.rm_f Config.instance.config.seen_tweets
    end

    context 'search' do
      let(:replacer) { described_class.new }

      it 'searches for tweets', :vcr do
        expect(replacer.search.class).to eq Array
      end

      it 'finds tweets', :vcr do
        expect(replacer.search.first.class).to eq Twitter::Tweet
      end

      it 'finds the correct tweets', :vcr do
        expect(replacer.search.first.text).to match /open ?data/i
        expect(replacer.search.all? { |tweet| tweet.text.match /open ?data/i }).to eq true
      end

      it 'finds English tweets', :vcr do
        expect(replacer.search.all? { |tweet| tweet.lang == 'en' }).to eq true
      end
    end

    context 'save last tweet' do
      let(:replacer) { described_class.new }

      it 'saves the ID of the last tweet', :vcr do
        replacer.save
        expect(File).to exist 'last.tweet'

        expect(Marshal.load File.read 'last.tweet').to eq 662228384039194624
      end

      it 'only saves if there is something to save', :vcr do
        File.open 'last.tweet', 'w' do |f|
          Marshal.dump 732591313607589889, f
        end

        replacer.save

        expect(Marshal.load File.read 'last.tweet').to eq 732591313607589889
      end
    end

    context 'only find new tweets', :vcr do
      let(:replacer) { described_class.new }

      it 'finds newer tweets', :vcr do
        File.open 'last.tweet', 'w' do |f|
          Marshal.dump 632591313607589889, f
        end

        expect(replacer.search.count).to eq 26
      end
    end

    context 'filtering on similar tweets' do
      let(:replacer) { described_class.new }

      it 'filters similar tweets', :vcr do
        SeenTweets.validate 'How open data can help save lives http://t.co/90U7bVq5UF'
        expect(replacer.tweets.count).to eq 25
      end
    end

    context 'tweet' do
      let(:replacer) { described_class.new }

      it 'prepares sensible tweets', :vcr do
        expect(replacer.tweets).to be_a Array
        expect(replacer.tweets.first).to eq 'CamTaylorSwift have booked your place weeks Taylor Swift session central cambridge https jpwajua8qb'
        expect(replacer.tweets[10]).to eq 'New #TaylorSwift book ed. by @leohavemann @jatenas https://t.co/umQvMtPm6W'
        expect(replacer.tweets.all? { |t| t.length <= 280} ).to eq true
      end

      it 'actually sends tweets', :vcr do
        expect(replacer.client).to(receive(:update)).exactly(26).times
        interval = replacer.config.interval
        replacer.config.interval = 0
        replacer.tweet
        replacer.config.interval = interval
      end

      it 'sends no tweets on a dry-run', :vcr do
        expect(replacer.client).to_not(receive(:update))
        replacer.tweet dry_run: true
      end
    end
  end
end
