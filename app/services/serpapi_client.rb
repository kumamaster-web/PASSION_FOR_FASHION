require 'httparty'

class SerpapiClient
  include HTTParty
  base_uri 'https://serpapi.com'

  def initialize
    @api_key = ENV['SERPAPI_KEY']
  end

  # Class method for easy access
  def self.products_for_fashion_answer(fashion_answer)
    new.products_for_fashion_answer(fashion_answer)
  end

  # Search Google Shopping for products with price filtering
  def search_products(query:, num: 10, price_min: nil, price_max: nil, currency: 'JPY')
    return [] unless @api_key.present?

    # Set location based on currency for better results
    gl = currency == 'JPY' ? 'jp' : 'us'
    hl = currency == 'JPY' ? 'ja' : 'en'

    query_params = {
      engine: 'google_shopping',
      q: query,
      api_key: @api_key,
      num: num,
      gl: gl,
      hl: hl
    }

    # Add price filters if provided
    if price_min.present? && price_max.present?
      query_params[:tbs] = "mr:1,price:1,ppr_min:#{price_min},ppr_max:#{price_max}"
    end

    response = self.class.get('/search.json', { query: query_params })

    parse_results(response, currency)
  rescue => e
    Rails.logger.error "SerpAPI error: #{e.message}"
    []
  end

  # Search by brand and color with price preference
  def search_by_style(brand:, color: nil, category: nil, gender: nil, num: 4, price_min: nil, price_max: nil, currency: 'JPY')
    gender_term = case gender&.downcase
                  when 'female' then "women's"
                  when 'male' then "men's"
                  else nil
                  end
    query_parts = [gender_term, color, category, brand].compact
    query = query_parts.join(' ')
    search_products(query: query, num: num, price_min: price_min, price_max: price_max, currency: currency)
  end

  # Fetch products for a fashion answer based on AI recommendations
  def products_for_fashion_answer(fashion_answer)
    return [] if fashion_answer.recommended_brands.blank?

    colors = fashion_answer.colour_palette&.split(',')&.first&.strip # get first color
    brands = fashion_answer.recommended_brands.split(',').map(&:strip)
    gender = fashion_answer.gender
    price_min = fashion_answer.price_min
    price_max = fashion_answer.price_max
    currency = fashion_answer.currency || 'JPY'

    products = []
    brands.first(3).each do |brand|
      results = search_by_style(
        brand: brand,
        color: colors,
        gender: gender,
        num: 4,
        price_min: price_min,
        price_max: price_max,
        currency: currency
      )
      products.concat(results)
    end

    products.take(12)
  rescue => e
    Rails.logger.error "SerpAPI products_for_fashion_answer error: #{e.message}"
    []
  end

  private

  def parse_results(response, currency = 'JPY')
    return [] unless response.success?

    data = response.parsed_response
    items = data['shopping_results'] || []

    currency_symbol = currency == 'JPY' ? '¥' : '$'

    items.map do |item|
      price_display = if item['extracted_price']
                        "#{currency_symbol}#{item['extracted_price'].to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
                      else
                        item['price']
                      end

      {
        title: item['title'],
        price: price_display,
        extracted_price: item['extracted_price'],
        thumbnail: item['thumbnail'],
        link: item['product_link'],
        source: item['source'],
        rating: item['rating'],
        reviews: item['reviews'],
        delivery: item['delivery'],
        currency: currency
      }
    end
  rescue => e
    Rails.logger.error "SerpAPI parse error: #{e.message}"
    []
  end
end
