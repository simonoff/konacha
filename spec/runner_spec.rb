require 'spec_helper'

describe Konacha::Runner do
  before do
    Konacha.mode = :runner
  end

  describe '.new' do
    it 'creates a reporter with formatters returned by Konacha.formatters' do
      expect(Konacha).to receive(:formatters) { :formatters }
      expect(Konacha::Reporter).to receive(:new).with(:formatters)
      described_class.new
    end

    it 'accepts an existing capybara session' do
      instance = described_class.new 'existing_session'
      expect(instance.session).to eq('existing_session')
    end
  end

  describe '.start' do
    it 'sets the Capybara.server_port' do
      expect(Capybara).to receive(:server_port=).with(Konacha.runner_port)
      allow_any_instance_of(Konacha::Runner).to receive(:run)
      Konacha::Runner.start
    end
  end

  shared_examples_for 'Konacha::Runner' do |driver|
    before do
      Konacha.configure do |config|
        config.driver = driver
        config.formatters = [Konacha::Formatter.new(StringIO.new)]
      end
    end

    describe '#run' do
      let(:suite) do
        { 'event' => 'suite',
          'type' => 'suite',
          'data' => {
            'title' => 'failure',
            'fullTitle' => 'failure',
            'path' => 'failing_spec.js'
          } }
      end

      let(:suite_end) do
        { 'event' => 'suite end',
          'type' => 'suite',
          'data' => {
            'title' => 'failure',
            'fullTitle' => 'failure',
            'path' => 'failing_spec.js'
          } }
      end

      let(:test) do
        { 'event' => 'test',
          'type'  => 'test',
          'data'  => {
            'title'           => 'fails',
            'fullTitle'       => 'failure fails',
            'parentFullTitle' => 'failure',
            'path'            => 'failing_spec.js' } }
      end

      let(:failure) do
        { 'event' => 'fail',
          'type'  => 'test',
          'data'  => {
            'title'           => 'fails',
            'fullTitle'       => 'failure fails',
            'parentFullTitle' => 'failure',
            'status'          => 'failed',
            'path'            => 'failing_spec.js',
            'error'           => { 'message' => 'expected 4 to equal 5', 'name' => 'AssertionError' } } }
      end

      let(:error) do
        { 'event' => 'fail',
          'type'  => 'test',
          'data'  => {
            'title'           => 'errors',
            'fullTitle'       => 'failure errors',
            'parentFullTitle' => 'failure',
            'status'          => 'failed',
            'path'            => 'failing_spec.js',
            'error'           => { 'message' => 'this one errors out', 'name' => 'Error' } } }
      end

      let(:error_async) do
        { 'event' => 'fail',
          'type'  => 'test',
          'data'  => {
            'title'           => 'errors asynchronously',
            'fullTitle'       => 'failure errors asynchronously',
            'parentFullTitle' => 'failure',
            'status'          => 'failed',
            'path'            => 'failing_spec.js',
            # Accept anything for 'message' since async errors have URLs, which
            # vary on every run, and line #, which may change in Chai releases.
            'error'           => { 'message' => anything, 'name' => 'Error' } } }
      end

      let(:pass) do
        { 'event' => 'pass',
          'type'  => 'test',
          'data'  => {
            'title'           => 'is empty',
            'fullTitle'       => 'the body#konacha element is empty',
            'parentFullTitle' => 'the body#konacha element',
            'status'          => 'passed',
            'path'            => 'body_spec.js.coffee',
            'duration'        => anything } }
      end

      let(:pending) do
        { 'event' => 'pending',
          'type'  => 'test',
          'data'  => {
            'title'           => 'is pending',
            'fullTitle'       => 'pending test is pending',
            'parentFullTitle' => 'pending test',
            'path'            => 'pending_spec.js',
            'status'          => 'pending' } }
      end

      let(:start)     { { 'event' => 'start', 'testCount' => kind_of(Integer), 'data' => {} } }
      let(:end_event) { { 'event' => 'end', 'data' => {} } }

      it 'passes along the right events' do
        expect(subject.reporter).to receive(:process_mocha_event).with(start)
        expect(subject.reporter).to receive(:process_mocha_event).with(suite)
        expect(subject.reporter).to receive(:process_mocha_event).with(suite_end)
        expect(subject.reporter).to receive(:process_mocha_event).with(test)
        expect(subject.reporter).to receive(:process_mocha_event).with(failure)
        expect(subject.reporter).to receive(:process_mocha_event).with(error)
        expect(subject.reporter).to receive(:process_mocha_event).with(error_async)
        expect(subject.reporter).to receive(:process_mocha_event).with(pass)
        expect(subject.reporter).to receive(:process_mocha_event).with(pending)
        expect(subject.reporter).to receive(:process_mocha_event).with(end_event)
        allow(subject.reporter).to receive(:process_mocha_event)
        subject.run
      end

      it 'accepts paths to test' do
        session = double('capybara session')
        allow(session).to receive(:evaluate_script).and_return([start, pass, end_event].to_json)
        expect(session).to receive(:visit).with('/test_path')

        instance = described_class.new session
        instance.run('/test_path')
      end
    end
  end

  describe 'with selenium' do
    it_behaves_like 'Konacha::Runner', :selenium
  end

  describe 'with poltergeist' do
    it_behaves_like 'Konacha::Runner', :poltergeist
  end
end
