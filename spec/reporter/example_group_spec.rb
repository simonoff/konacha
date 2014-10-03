require 'spec_helper'

describe Konacha::Reporter::ExampleGroup do
  subject { described_class.new({}, nil) }

  describe '#initialize' do
    it 'loads up a metadata instance and the parent' do
      data = double('data')
      parent_metadata = Konacha::Reporter::Metadata.new({})
      parent = double('parent', metadata: parent_metadata)

      # Check if parent metadata is added to metadata
      allow_any_instance_of(described_class).to receive(:update_metadata) { nil }
      expect_any_instance_of(described_class).to receive(:update_metadata).with(example_group: parent_metadata)

      example_group = described_class.new(data, parent)
      expect(example_group.parent).to eq(parent)
      expect(example_group.metadata).to be_a(Konacha::Reporter::Metadata)
      expect(example_group.metadata.data).to eq(data)
    end
  end

  describe 'delegated methods' do
    let(:metadata) { double('metadata') }
    before { allow(Konacha::Reporter::Metadata).to receive(:new) { metadata } }

    [:full_description, :description, :file_path, :described_class].each do |method|
      it "delegates #{method} to metadata" do
        expect(metadata).to receive(method)
        subject.send(method)
      end
    end
  end

  describe 'aliased_methods' do
    it 'aliases display_name to description' do
      expect(subject.display_name).to eq(subject.description)
    end
  end

  describe '#parent_groups' do
    let(:parent) { double('parent') }
    let(:grandparent) { double('grandparent') }

    before do
      allow(grandparent).to receive_messages(parent: nil)
      allow(parent).to receive_messages(parent: grandparent)
      allow(subject).to receive_messages(parent: parent)
    end

    it "finds all of this group's ancestors" do
      expect(subject.parent_groups).to eq([parent, grandparent])
    end

    it 'works via #ancestors' do
      expect(subject.ancestors).to eq([parent, grandparent])
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
