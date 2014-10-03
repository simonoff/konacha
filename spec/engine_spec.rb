require 'spec_helper'

describe Konacha::Engine do
  describe '.formatters' do
    it 'defaults to a Konacha::Formatter pointing to STDOUT' do
      expect(Konacha::Formatter).to receive(:new).with(STDOUT) { :formatter }
      expect(Konacha::Engine.formatters).to eq([:formatter])
    end

    context 'with a FORMAT environment variable' do
      before do
        class TestFormatter
          def initialize(_io)
          end
        end
        ENV['FORMAT'] = 'Konacha::Formatter,TestFormatter'
      end

      after do
        Object.send(:remove_const, :TestFormatter)
        ENV.delete('FORMAT')
      end

      it 'creates the specified formatters' do
        expect(Konacha::Formatter).to receive(:new).with(STDOUT) { :formatter }
        expect(TestFormatter).to receive(:new).with(STDOUT) { :test_formatter }
        expect(Konacha::Engine.formatters).to eq([:formatter, :test_formatter])
      end
    end
  end
end
