# frozen_string_literal: true

# spec/controllers/scraper_controller_spec.rb

require 'rails_helper'

RSpec.describe ScraperController, type: :controller do
  describe '#data' do
    it 'calls UrlScraper.scrape_data with permitted params' do
      url = 'https://www.example.com'
      fields = { 'price' => '.price-box__price', 'rating_count' => '.ratingCount' }
      meta = { 'meta_key' => '.metaSelector' }

      allow(UrlScraper).to receive(:scrape_data).and_return({})

      post :data, params: { url:, fields:, meta: }

      expect(UrlScraper).to have_received(:scrape_data).with(url, fields, nil)
    end

    it 'renders JSON response' do
      allow(UrlScraper).to receive(:scrape_data).and_return({})

      post :data, params: { url: 'https://www.example.com', fields: {}, meta: {} }

      expect(response.content_type).to eq('application/json; charset=utf-8')
    end
  end
end
# frozen_string_literal: true
