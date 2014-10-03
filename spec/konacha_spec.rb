require 'spec_helper'

describe Konacha do
  describe '.config' do
    subject { Konacha.config }

    describe '.spec_dir' do
      it "defaults to 'spec/javascripts'" do
        expect(subject.spec_dir).to eq('spec/javascripts')
      end
    end

    describe '.spec_matcher' do
      it "defaults to /_spec\.|_test\./" do
        expect(subject.spec_matcher).to eq(/_spec\.|_test\./)
      end
    end

    describe '.runner_port' do
      it 'defaults to nil' do
        expect(subject.runner_port).to eq(nil)
      end
    end
  end

  describe '.spec_paths' do
    subject { Konacha.spec_paths }

    it 'returns an array of paths relative to spec_dir' do
      expect(subject).to include('array_sum_js_spec.js')
      expect(subject).to include('array_sum_cs_spec.js.coffee')
    end

    it 'includes subdirectories' do
      expect(subject).to include('subdirectory/subdirectory_spec.js')
    end

    it "doesn't dup paths" do
      expect(subject).to eq(subject.uniq)
    end

    it 'traverses symlinked directories' do
      begin
        # Create a directory with specs outside of 'spec/javascripts'.
        Dir.mkdir 'spec/dummy/app/external_specs'
        File.new 'spec/dummy/app/external_specs/my_spec.js', 'w'

        # Symlink it into 'spec/javascripts'.
        File.symlink '../../app/external_specs/', 'spec/dummy/spec/javascripts/external_specs'

        expect(subject).to include('external_specs/my_spec.js')

        File.unlink 'spec/dummy/spec/javascripts/external_specs'
      rescue NotImplementedError
        # Don't test this on platforms that don't support symlinking.
      end

      File.unlink 'spec/dummy/app/external_specs/my_spec.js'
      Dir.unlink 'spec/dummy/app/external_specs'
    end

    it 'does not include spec_helper' do
      expect(subject).not_to include('spec_helper.js')
    end

    it 'includes *_test.* files' do
      expect(subject).to include('file_ending_in_test.js')
    end

    it 'only includes JavaScript files' do
      expect(subject).not_to include('do_not_include_spec.png')
    end

    it 'does not include non-asset files' do
      expect(subject).not_to include('do_not_include_spec.js.bak')
    end

    describe 'with a custom matcher' do
      after { Konacha.config.spec_matcher = /_spec\.|_test\./ }

      it 'includes *-spec.* files' do
        Konacha.config.spec_matcher = /-spec\./
        expect(subject).to include('file-with-hyphens-spec.js')
      end

      it 'includes *.spec.* files' do
        Konacha.config.spec_matcher = /\.spec\./
        expect(subject).to include('file.with.periods.spec.js')
      end

      it 'works with any object responding to ===' do
        Konacha.config.spec_matcher = Module.new do
          def self.===(path)
            path == 'array_sum_js_spec.js'
          end
        end
        expect(subject).to include('array_sum_js_spec.js')
        expect(subject.size).to eq(1)
      end
    end
  end

  it 'can be configured in an initializer' do
    expect(Konacha.config.configured).to eq(true)
  end
end
