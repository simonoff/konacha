require 'spec_helper'

describe Konacha::Reporter::Example do
  subject { described_class.new({}, nil) }

  describe '#initialize' do
    it 'loads up a metadata instance and the parent' do
      data = double('data')
      parent_metadata = Konacha::Reporter::Metadata.new({})
      parent = double('parent', metadata: parent_metadata)

      # Check if parent metadata is added to metadata
      allow_any_instance_of(described_class).to receive(:update_metadata) { nil }
      expect_any_instance_of(described_class).to receive(:update_metadata).with(example_group: parent_metadata)

      example = described_class.new(data, parent)
      expect(example.parent).to eq(parent)
      expect(example.metadata).to be_a(Konacha::Reporter::Metadata)
      expect(example.metadata.data).to eq(data)
    end
  end

  describe 'delegated methods' do
    let(:metadata) { double('metadata') }
    before { allow(Konacha::Reporter::Metadata).to receive(:new) { metadata } }

    [:full_description, :description, :location, :file_path, :line_number, :pending, :pending_message, :exception, :execution_result].each do |method|
      it "delegates #{method} to metadata" do
        expect(metadata).to receive(method)
        subject.send(method)
      end
    end
  end

  describe 'aliased_methods' do
    it 'aliases pending? to pending' do
      expect(subject.pending?).to eq(subject.pending)
    end

    it 'aliases options to metadata' do
      expect(subject.options).to eq(subject.metadata)
    end

    it 'aliases example_group to parent' do
      expect(subject.example_group).to eq(subject.parent)
    end
  end

  describe '#passed?' do
    it 'returns true iff execution_result[:status] is passed' do
      expect(subject).to receive(:execution_result) { { status: 'passed' } }
      expect(subject.passed?).to be_truthy
    end

    it 'returns false' do
      expect(subject).to receive(:execution_result) { {} }
      expect(subject.passed?).to be_falsey
    end
  end

  describe '#failed?' do
    it 'returns true iff execution_result[:status] is failed' do
      expect(subject).to receive(:execution_result) { { status: 'failed' } }
      expect(subject.failed?).to be_truthy
    end

    it 'returns false' do
      expect(subject).to receive(:execution_result) { {} }
      expect(subject.failed?).to be_falsey
    end
  end

  describe '#update_metadata' do
    it 'calls metadata.update' do
      data = double('data')
      metadata = double('metadata')
      expect(metadata).to receive(:update).with(data)
      allow(Konacha::Reporter::Metadata).to receive(:new) { metadata }
      subject.update_metadata(data)
    end
  end

  describe '#[]' do
    it 'should delegate to instance method if it exists' do
      allow(subject).to receive(:some_method) { nil }
      allow(subject).to receive(:metadata) { nil }
      expect(subject).to receive(:some_method)
      expect(subject).not_to receive(:metadata)
      subject[:some_method]
    end

    it 'should delegate to metadata if no method exists' do
      expect(subject).not_to respond_to(:some_method)
      allow(subject.metadata).to receive(:[]) { nil }
      expect(subject.metadata).to receive(:[]).with(:some_method)
      subject[:some_method]
    end
  end
end
