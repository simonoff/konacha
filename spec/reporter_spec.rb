require 'spec_helper'

describe Konacha::Reporter do
  let(:formatter) { double('formatter').as_null_object }
  subject { described_class.new(formatter) }

  describe '#start' do
    it 'sets the start time to the current time' do
      subject.start
      expect(subject.start_time).to be_within(1.second).of(Time.now)
    end

    it 'processes the start event' do
      expect(subject).to receive(:process_event).with(:start, nil)
      subject.start
    end
  end

  describe '#finish' do
    it 'calls #stop' do
      expect(subject).to receive(:stop)
      subject.finish
    end

    it 'processes events' do
      allow(subject).to receive(:stop)
      expect(subject).to receive(:process_event).with(:start_dump).ordered
      expect(subject).to receive(:process_event).with(:dump_pending).ordered
      expect(subject).to receive(:process_event).with(:dump_failures).ordered
      expect(subject).to receive(:process_event).with(:dump_summary, nil, 0, 0, 0).ordered
      expect(subject).to receive(:process_event).with(:close).ordered
      subject.finish
    end
  end

  describe '#stop' do
    it 'calculates duration' do
      subject.start
      subject.stop
      expect(subject.duration).not_to be_nil
    end

    it 'processes the stop event' do
      expect(subject).to receive(:process_event).with(:stop)
      subject.stop
    end
  end

  describe '#process_mocha_event' do
    before { allow(subject).to receive(:process_event) }

    it 'calls #start if passed the start event' do
      expect(subject).to receive(:start).with(4)
      subject.process_mocha_event('event' => 'start', 'testCount' => 4)
    end

    it 'calls #finish if passed the end event' do
      expect(subject).to receive(:finish)
      subject.process_mocha_event('event' => 'end')
    end

    it 'creates the object' do
      expect(subject).to receive(:update_or_create_object).with('data', 'type')
      subject.process_mocha_event('data' => 'data', 'event' => 'test', 'type' => 'type')
    end

    it 'calls #process_event with the converted event name' do
      object = double('test')
      allow(subject).to receive(:update_or_create_object) { object }
      expect(subject).to receive(:process_event).with(:example_started, object)
      subject.process_mocha_event('event' => 'test', 'type' => 'test')
    end

    it 'calls #process_event twice for pending examples' do
      object = double('test')
      allow(subject).to receive(:update_or_create_object) { object }
      expect(subject).to receive(:process_event).with(:example_started, object)
      expect(subject).to receive(:process_event).with(:example_pending, object)
      subject.process_mocha_event('event' => 'pending', 'type' => 'test')
    end
  end

  describe '#process_event' do
    it 'forwards the call on to the formatters' do
      expect(formatter).to receive(:example_started).with('arg!')
      subject.process_event(:example_started, 'arg!')
    end
  end

  describe '#update_or_create_object' do
    describe 'creates the right type of object' do
      it 'creates example if test' do
        expect(subject.update_or_create_object({}, 'test')).to be_a(Konacha::Reporter::Example)
      end

      it 'creates example_group if suite' do
        expect(subject.update_or_create_object({}, 'suite')).to be_a(Konacha::Reporter::ExampleGroup)
      end
    end

    it 'updates if the object with same fullTitle exists' do
      data = { 'fullTitle' => 'title' }
      object = subject.update_or_create_object(data, 'test')
      expect(object).to receive(:update_metadata).with(data)
      expect(subject.update_or_create_object(data, 'test')).to eq(object)
    end

    it 'links up the parent correctly' do
      suite = subject.update_or_create_object({ 'fullTitle' => 'suite' }, 'suite')
      object = subject.update_or_create_object({ 'fullTitle' => 'suite awesome', 'parentFullTitle' => 'suite' }, 'test')
      expect(object.parent).to eq(suite)
    end
  end

  describe '#passed?' do
    it 'passes if failure count is zero' do
      expect(subject).to be_passed
    end

    it 'does not pass if failure count is not zero' do
      allow(subject).to receive_messages(failure_count: 1)
      expect(subject).not_to be_passed
    end
  end

  context 'counters' do
    describe '#example_count' do
      it 'is 0 by default' do
        expect(subject.example_count).to be_zero
      end

      it 'returns examples count' do
        allow(subject).to receive_messages(examples: { omg: :two, examples: :wow })
        expect(subject.example_count).to eq(2)
      end
    end

    describe '#pending_count' do
      it 'returns pending examples count' do
        allow(subject).to receive_messages(examples: { first: double(:pending? => true), second: double(:pending? => false) })
        expect(subject.pending_count).to eq(1)
      end
    end

    describe '#failure_count' do
      it 'returns failed examples count' do
        allow(subject).to receive_messages(examples: { first: double(:failed? => true), second: double(:failed? => false) })
        expect(subject.failure_count).to eq(1)
      end
    end
  end
end
