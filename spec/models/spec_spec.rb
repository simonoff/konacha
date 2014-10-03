require 'spec_helper'

describe Konacha::Spec, type: :model do
  describe '#asset_name' do
    it 'is the asset_name of the path' do
      expect(described_class.new('array_spec.js').asset_name).to eq('array_spec')
      expect(described_class.new('array_spec.coffee').asset_name).to eq('array_spec')
    end

    it 'ignores multiple extensions' do
      expect(described_class.new('array_spec.js.coffee').asset_name).to eq('array_spec')
    end

    it 'includes relative path' do
      expect(described_class.new('subdirectory/array_spec.js').asset_name).to eq('subdirectory/array_spec')
    end
  end

  describe '.all' do
    it 'returns an array of specs' do
      expect(Konacha).to receive(:spec_paths) { ['a_spec.js', 'b_spec.js'] }
      all = described_class.all
      expect(all.length).to eq(2)
    end

    it "returns specs passed via the ENV['spec'] parameter" do
      ENV['SPEC'] = 'foo_spec,bar_spec,baz_spec'
      all = described_class.all
      expect(all.length).to eq(3)
      paths = all.map { |p| p.path }
      paths =~ %w(      foo_spec bar_spec baz_spec      )
      ENV['SPEC'] = nil
    end

    it 'returns all Specs if given an empty path' do
      all = ['a_spec.js', 'b_spec.js']
      expect(Konacha).to receive(:spec_paths) { all }
      expect(described_class.all('').map(&:path)).to eq(all)
    end

    it 'returns an array containing the Spec with the given asset_name' do
      all = ['a_spec.js', 'b_spec.js']
      expect(Konacha).to receive(:spec_paths) { all }
      expect(described_class.all('b_spec').map(&:path)).to eq([all[1]])
    end

    it 'returns Specs that are children of the given path' do
      all = ['a/a_spec_1.js', 'a/a_spec_2.js', 'b/b_spec.js']
      expect(Konacha).to receive(:spec_paths) { all }
      expect(described_class.all('a').map(&:path)).to eq(all[0..1])
    end

    it 'raises NotFound if no Specs match' do
      expect(Konacha).to receive(:spec_paths) { [] }
      expect { described_class.all('b_spec') }.to raise_error(Konacha::Spec::NotFound)
    end
  end

  describe '.find_by_name' do
    it 'returns the spec with the given asset name' do
      all = ['a_spec.js', 'b_spec.js']
      expect(Konacha).to receive(:spec_paths) { all }
      expect(described_class.find_by_name('a_spec').path).to eq('a_spec.js')
    end

    it 'raises NotFound if no Specs match' do
      expect(Konacha).to receive(:spec_paths) { [] }
      expect { described_class.find_by_name('b_spec') }.to raise_error(Konacha::Spec::NotFound)
    end
  end
end
