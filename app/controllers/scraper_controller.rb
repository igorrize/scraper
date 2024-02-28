# frozen_string_literal: true

class ScraperController < ApplicationController
  def data
    data = UrlScraper.scrape_data(permitted_params[:url], permitted_params[:fields], permitted_params[:meta])
    render json: data
  end

  private

  def permitted_params
    params.permit(:url, fields: {}).to_h
  end
end
