# spec/services/scraper_spec.rb
require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Scraper do
  describe '.scrape_data' do
    let(:url) { 'https://www.example.com' }
    let(:fields) { { 'title' => '.title', 'description' => '.description' } }
    let(:metadata) { %w[.author .published-date] }

    before do
      stub_request(:get, url)
        .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'example_page.html')), headers: { 'Content-Type' => 'text/html' })
    end

    it 'scrapes data without metadata' do
      result = Scraper.scrape_data(url, fields, nil)
      expect(result).to include('title' => 'Example Title', 'description' => 'Example Description')
      expect(result[:meta]).to be_nil
    end

    it 'scrapes data with metadata' do
      result = Scraper.scrape_data(url, fields, metadata)
      expect(result).to include('title' => 'Example Title', 'description' => 'Example Description')
      expect(result[:meta]).to_not be_nil
      expect(result[:meta]).to include('Author Name', 'Published Date')
    end
  end
end
