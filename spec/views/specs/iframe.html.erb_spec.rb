require 'spec_helper'

describe 'konacha/specs/iframe', type: :view do
  before do
    assign(:stylesheets, [])
    assign(:javascripts, [])
  end

  def spec_double(asset_name)
    double("spec called '#{asset_name}'", asset_name: asset_name, path: "#{asset_name}.js")
  end

  it 'renders a script tag for @spec' do
    assign(:spec, spec_double('a_spec'))

    allow(view).to receive(:javascript_include_tag)
    expect(view).to receive(:javascript_include_tag).with(debug: false).ordered
    expect(view).to receive(:javascript_include_tag).with('a_spec').ordered

    render
  end

  it 'renders the stylesheets' do
    assign(:spec, spec_double('a_spec'))
    assign(:stylesheets, %w(foo bar))

    expect(view).to receive(:stylesheet_link_tag).with('foo', debug: false)
    expect(view).to receive(:stylesheet_link_tag).with('bar', debug: false)

    render
  end

  it 'renders the javascripts' do
    assign(:spec, spec_double('a_spec'))
    assign(:javascripts, %w(foo bar))

    expect(view).to receive(:javascript_include_tag).with('foo', 'bar', debug: false).ordered
    expect(view).to receive(:javascript_include_tag).with('a_spec').ordered

    render
  end

  it 'includes a path data attribute' do
    assign(:spec, spec_double('a_spec'))

    render

    expect(rendered).to have_selector("[data-path='a_spec.js']")
  end
end
