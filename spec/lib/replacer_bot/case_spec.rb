module ReplacerBot
  describe 'Helpers' do
    context 'case handling' do
      it 'has case variants for replacements' do
        expect(ReplacerBot.replacement_caser 'Open Data' => 'Taylor Swift').
        to eq(
          [
            {'OPEN DATA' => 'TAYLOR SWIFT'},
            {'open data' => 'Taylor Swift'},
            {'Open Data' => 'Taylor Swift'}
          ]
        )

        expect(ReplacerBot.replacement_caser 'blockchain' => 'Beyoncé').
        to eq(
          [
            {'BLOCKCHAIN' => 'BEYONCÉ'},
            {'blockchain' => 'Beyoncé'},
            {'Blockchain' => 'Beyoncé'}
          ]
        )

        expect(ReplacerBot.replacement_caser 'cyber' => 'spider').
        to eq(
          [
            {'CYBER' => 'SPIDER'},
            {'cyber' => 'spider'},
            {'Cyber' => 'Spider'}
          ]
        )
      end

      it 'preserves case when replacing' do
        expect(ReplacerBot.replace string: 'Open Data').to eq 'Taylor Swift'
        expect(ReplacerBot.replace string: 'OPEN DATA').to eq 'TAYLOR SWIFT'
        expect(ReplacerBot.replace string: 'OPEn DAta').to eq 'Taylor Swift'
        expect(ReplacerBot.replace string: 'OPEN DATA Open Data open data').to eq 'TAYLOR SWIFT Taylor Swift Taylor Swift'
      end
    end
  end
end
