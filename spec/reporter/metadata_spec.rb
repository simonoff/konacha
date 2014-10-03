require 'spec_helper'

describe Konacha::Reporter::Metadata do
  subject { described_class.new({}) }

  describe '#[]' do
    it 'calls the method on self if available' do
      expect(subject).to receive(:full_description)
      subject[:full_description]
    end

    it 'looks in the data hash' do
      expect(subject).to receive(:data) { {} }
      subject[:title]
    end
  end

  describe '#update' do
    it 'merges the new data into the data hash' do
      subject.update(title: 'test')
      expect(subject.data).to eq(title: 'test')
    end
  end

  describe '#exception' do
    it 'returns unless the spec failed' do
      expect(subject.exception).to be_nil
    end

    it 'builds a SpecException object' do
      subject.update('status' => 'failed', 'error' => { 'name' => 'Error', 'message' => 'expected this to work' })
      expect(subject.exception).to be_a(Konacha::Reporter::SpecException)
      expect(subject.exception.message).to eq('Error: expected this to work')
      expect(subject.exception.backtrace).to eq([])
    end
  end

  describe '#execution_result' do
    it 'returns a hash with execution details' do
      expect(subject.execution_result.keys.map(&:to_s).sort).to eq([:exception, :finished_at, :run_time, :started_at, :status].map(&:to_s))
    end
  end

  describe '#pending' do
    it 'returns true iff status is pending' do
      subject.update('status' => 'pending')
      expect(subject.pending).to be_truthy
    end

    it 'returns false' do
      expect(subject.pending).to be_falsey
    end
  end

  shared_examples_for 'data delegation method' do |key, method|
    it "returns data['#{key}']" do
      subject.update(key => 'super test')
      expect(subject.send(method)).to eq('super test')
    end
  end

  describe '#file_path' do
    it_behaves_like 'data delegation method', 'path', 'file_path'
  end

  describe '#description' do
    it_behaves_like 'data delegation method', 'title', 'description'
  end

  describe '#full_description' do
    it_behaves_like 'data delegation method', 'fullTitle', 'full_description'
  end
end
