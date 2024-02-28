# frozen_string_literal: true

# spec/services/scraper_spec.rb
require 'rails_helper'
require 'webmock/rspec'

RSpec.describe UrlScraper do
  describe '.scrape_data' do
    let(:url) { 'https://www.example.com' }
    let(:fields) { { 'title' => '.title', 'description' => '.description' } }
    let(:metadata) { %w[keywords twitter:image] }

    context 'when cache is present' do
      before do
        Rails.cache.write("scraper_data:#{url}", { '.title' => 'Cached Title', meta: { 'author' => 'Cached Author' } })
      end

      it 'returns data from cache' do
        result = described_class.scrape_data(url, fields, metadata)
        expect(result).to include('description' => nil, 'title' => 'Cached Title',
                                  :meta => { 'keywords' => nil, 'twitter:image' => nil })
      end
    end

    context 'when cache is not present' do
      before do
        stub_request(:get, url)
          .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'example_page.html')),
                     headers: { 'Content-Type' => 'text/html' })
      end

      it 'scrapes data without metadata' do
        result = UrlScraper.scrape_data(url, fields, nil)
        expect(result).to include('title' => 'Example Title', 'description' => 'Example Description')
        expect(result[:meta]).to be_nil
      end

      it 'scrapes data with metadata' do
        result = UrlScraper.scrape_data(url, fields, metadata)
        expect(result).to include('title' => 'Example Title', 'description' => 'Example Description')
        expect(result[:meta]).to_not be_nil
        expect(result[:meta]).to include('keywords' => 'random words',
                                         'twitter:image' => 'random url for image')
      end
    end
  end
end
