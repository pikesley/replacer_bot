module ReplacerBot
  describe Config do
    let(:conf) { ReplacerBot::Config.instance.config }

    it 'has defaults' do
      expect(conf['search_term']).to eq 'open data'
    end
  end
end
