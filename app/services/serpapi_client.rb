class SerpapiClient
  include HTTParty
  base_uri 'https://serpapi.com'

  def initialize
    @api_key = ENV['SERPAPI_KEY']
  end

  # Search Google Shopping for products
  def search_products(query:, num: 10)
    return [] unless @api_key.present?

    response = self.class.get('/search.json', {
      query: {
        engine: 'google_shopping',
        q: query,
        api_key: @api_key,
        num: num,
        gl: 'us',
        hl: 'en'
      }
    })

    parse_results(response)
  rescue => e
    Rails.logger.error "SerpAPI error: #{e.message}"
    []
  end

  # Search by brand and color
  def search_by_style(brand:, color: nil, category: nil, gender: nil, num: 4)
    gender_term = case gender&.downcase
                  when 'female' then "women's"
                  when 'male' then "men's"
                  else nil
                  end
    query_parts = [gender_term, color, category, brand].compact
    query = query_parts.join(' ')
    search_products(query: query, num: num)
  end

  # Fetch products for a fashion answer based on AI recommendations
  def products_for_fashion_answer(fashion_answer)
    return [] if fashion_answer.recommended_brands.blank?

    colors = fashion_answer.colour_palette&.split(',')&.first&.strip
    brands = fashion_answer.recommended_brands.split(',').map(&:strip)
    gender = fashion_answer.gender

    products = []
    brands.first(3).each do |brand|
      results = search_by_style(brand: brand, color: colors, gender: gender, num: 4)
      products.concat(results)
    end

    products.take(12)
  rescue => e
    Rails.logger.error "SerpAPI products_for_fashion_answer error: #{e.message}"
    []
  end

  private

  def parse_results(response)
    return [] unless response.success?

    data = response.parsed_response
    items = data['shopping_results'] || []

    items.map do |item|
      {
        name: item['title'],
        price: item['extracted_price'] ? "$#{item['extracted_price']}" : item['price'],
        image_url: item['thumbnail'],
        product_url: item['link'],
        source: item['source'],
        rating: item['rating'],
        reviews: item['reviews'],
        delivery: item['delivery']
      }
    end
  rescue => e
    Rails.logger.error "SerpAPI parse error: #{e.message}"
    []
  end
end
