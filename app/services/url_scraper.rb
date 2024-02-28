# frozen_string_literal: true

class UrlScraper
  class << self
    require 'nokogiri'
    require 'open-uri'

    def scrape_data(url, fields, metadata_selectors = nil)
      cache_key = "scraper_data:#{url}"

      cached_data = Rails.cache.fetch(cache_key, expires_in: 24.hours) do
        fetch_data(url, fields, metadata_selectors)
      end

      result = {}
      fields.each do |field_name, selector|
        result[field_name] = cached_data[selector]
      end

      if metadata_selectors
        result[:meta] = {}

        metadata_selectors.each { |meta_name| result[:meta][meta_name] = cached_data.dig(:meta, meta_name) }
      end

      result
    end

    private

    def fetch_data(url, fields, metadata_selectors)
      begin
        page = Nokogiri::HTML(URI.open(url))
      rescue OpenURI::HTTPError => e
        return { error: "Invalid URL: #{url} or #{e}" }
      end

      cached_data = Rails.cache.read("scraper_data:#{url}") || { meta: {} }
      uncached_fields = fields.reject { |_, selector| cached_data[selector] }
      uncached_fields.each_value { |selector| cached_data[selector] = page.css(selector).text.strip }

      metadata_selectors&.each do |selector|
        cached_data[:meta][selector] ||= page.at("meta[name=\"#{selector}\"]").try(:[], 'content')
      end

      Rails.cache.write("scraper_data:#{url}", cached_data, expires_in: 24.hours)

      cached_data
    end
  end
end
