require 'spec_helper'

describe Konacha::SpecsController, type: :controller do
  before do
    @routes = Konacha::Engine.routes
  end

  describe '#parent' do
    it 'accepts a mode parameter and assigns it to @run_mode' do
      get :parent, mode: 'runner'
      expect(assigns[:run_mode]).to be_runner
    end

    it 'uses the Konacha.mode if no mode parameter is specified' do
      allow(Konacha).to receive_messages(mode: :konacha_mode)
      get :parent
      expect(assigns[:run_mode]).to be_konacha_mode
    end
  end

  describe '#iframe' do
    it 'assigns the result of Spec.find_by_name to @spec' do
      expect(Konacha::Spec).to receive(:find_by_name).with('spec_name') { :spec }
      get :iframe, name: 'spec_name'
      expect(assigns[:spec]).to eq(:spec)
      expect(assigns[:stylesheets]).to eq(Konacha::Engine.config.konacha.stylesheets)
      expect(assigns[:javascripts]).to eq(Konacha::Engine.config.konacha.javascripts)
    end

    it '404s if there is no match for the given path' do
      expect(Konacha::Spec).to receive(:find_by_name).with('array_spec') { fail Konacha::Spec::NotFound }
      get :iframe, name: 'array_spec'
      expect(response.status).to eq(404)
      expect(response).not_to render_template('konacha/specs/iframe')
    end
  end
end
