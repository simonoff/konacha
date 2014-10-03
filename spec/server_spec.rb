require 'spec_helper'

describe Konacha::Server, type: :feature do
  before do
    Konacha.mode = :server
  end

  it 'serves a root page' do
    visit '/'
    expect(page).to have_content('Array#sum (js)')
    expect(page).to have_css('.test.pass')
  end

  it 'serves an individual JavaScript spec' do
    visit '/array_sum_js_spec'
    expect(page).to have_content('Array#sum (js)')
    expect(page).to have_css('.test.pass', count: 2)
  end

  it 'serves an individual CoffeeScript spec' do
    visit '/array_sum_cs_spec'
    expect(page).to have_content('Array#sum (cs)')
    expect(page).to have_css('.test.pass', count: 2)
  end

  it 'serves a spec in a subdirectory' do
    visit '/subdirectory/subdirectory_spec'
    expect(page).to have_content('spec in subdirectory')
    expect(page).to have_css('.test.pass')
  end

  it 'serves a subdirectory of specs' do
    visit '/subdirectory'
    expect(page).to have_content('spec in subdirectory')
    expect(page).to have_css('.test.pass')
  end

  it 'serves a file with a period in the name' do
    visit '/jquery.plugin_spec'
    expect(page).to have_content('jQuery.fn.plugin()')
    expect(page).to have_css('.test.pass', count: 1)
  end

  it 'supports spec helpers' do
    visit '/spec_helper_spec'
    expect(page).to have_content('two_plus_two')
    expect(page).to have_css('.test.pass')
  end
end
