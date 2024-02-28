class Scraper
  class << self
    require 'nokogiri'
    require 'open-uri'

    def scrape_data(url, fields, metadata_selectors)
      page = Nokogiri::HTML(URI.open(url))
      result = {}
      cache_key = "scraper_data:#{url}"
      cached_data = Rails.cache.read(cache_key)

      fields.each do |field_name, selector|
        result[field_name] = cached_data[selector] || page.css(selector).text.strip
      end

      if metadata_selectors
        metadata_selectors.each do |meta_name, selector|
          result[:meta][meta_name] = cached_data[:meta][selector] || page.css(selector).text.strip
        end
      end

      cached_data.merge!(result)
      Rails.cache.write(cache_key, cached_data, expires_in: 24.hour)

      result
    end
  end
end
