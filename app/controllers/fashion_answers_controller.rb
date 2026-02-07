require 'base64'

class FashionAnswersController < ApplicationController
  before_action :authenticate_user!

  def new
    @fashion_answer = FashionAnswer.new
  end

  def create
    @fashion_answer = current_user.fashion_answers.new(fashion_answer_params)

    # Upload image to Cloudinary
    if params[:fashion_answer][:user_image].present?
      @fashion_answer.user_image.attach(params[:fashion_answer][:user_image])
      result = Cloudinary::Uploader.upload(params[:fashion_answer][:user_image])
      @fashion_answer.image_path = result["secure_url"]
    end



    if @fashion_answer.save
      # Generate AI advice
      @ruby_llm_chat = RubyLLM.chat(model: "gpt-4o")

      @generated_image = RubyLLM.paint(image_prompt(@fashion_answer))

      # image_prompt = "a guy in a shirt and suit looks fashion"
      # save the image as a attachment on fashion_answer instance
      #

      #   @fashion_answer.generated_image.attach(
      #     io: StringIO.new(@response.data),
      #     filename: "generated_image.png",
      #     content_type: "image/png"
      #   )
      # end

      filename = "generated_image.png"

      # Use StringIO to provide an IO object to Active Storage
      image_io = StringIO.new(@generated_image.to_blob)

      @fashion_answer.generated_image.attach(
        io: image_io,
        filename: filename,
        content_type:  'image/png'
      )

      redirect_to @fashion_answer, notice: "Your fashion answer was created."
    else
      render :new, status: :unprocessable_entity
    end
  end


  def show
    @fashion_answer = current_user.fashion_answers.find(params[:id])
    @products = fetch_product_recommendations(@fashion_answer)
    @existing_chat = current_user.chats.find_by(fashion_answer: @fashion_answer)
  end

  def index
    @fashion_answers = current_user.fashion_answers.order(created_at: :desc)
  end

  private

  def fashion_answer_params
    params.require(:fashion_answer).permit(:lifestyle, :colors, :occasion, :comfort, :statement, :personality_type, :gender, :price_min, :price_max, :currency, :user_image)
  end

  def fetch_product_recommendations(answer)
    return [] unless answer.recommended_brands.present?

    # Use Rails cache to avoid repeated API calls
    cache_key = "products_#{answer.id}_#{answer.updated_at.to_i}"
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      SerpapiClient.products_for_fashion_answer(answer)
    end
  rescue => e
    Rails.logger.error "SerpAPI Error: #{e.message}"
    []
  end

  def image_prompt(answer)
    <<~PROMPT
      Based on the following fashion preferences, provide personalized style advice and generate a image
        Gender: #{answer.gender}
        Lifestyle: #{answer.lifestyle}
        Favorite Colors: #{answer.colors}
        Main Occasion: #{answer.occasion}
        Comfort Preference: #{answer.comfort}
        Style Statement: #{answer.statement}
        Personality Type: #{answer.personality_type}
        User Image: #{Base64.strict_encode64(@fashion_answer.user_image.download)}
    PROMPT
  end

  def generate_advice(answer)
    gender_context = answer.gender.present? ? "Gender: #{answer.gender}\n      " : ""
    price_context = if answer.price_min.present? && answer.price_max.present?
                      "Budget: #{answer.price_min}-#{answer.price_max} #{answer.currency} per item\n      "
                    else
                      ""
                    end
    prompt = <<~PROMPT
      Based on the following fashion preferences, provide personalized style advice:

      #{gender_context}#{price_context}Lifestyle: #{answer.lifestyle}
      Favorite Colors: #{answer.colors}
      Main Occasion: #{answer.occasion}
      Comfort Preference: #{answer.comfort}
      Style Statement: #{answer.statement}
      Personality Type: #{answer.personality_type}

      Please provide:
      1. A two-word persona tagline (like "Creative Trendsetter" or "Bold Minimalist")
      2. A recommended style description (2-3 sentences)
      3. A colour palette suggestion (list 4-5 colors)
      4. Recommended brands (list 3-4 brands)
      5. Where to shop (list 2-3 stores)

      Format your response exactly like this:
      PERSONA: [two word tagline]
      STYLE: [your style recommendation]
      COLOURS: [comma separated colors]
      BRANDS: [comma separated brands]
      SHOPS: [comma separated shops]
    PROMPT

    max_retries = 5
    retry_count = 0
    base_delay = 3 # seconds

    begin
      Rails.logger.info "AI request start fashion_answer_id=#{answer.id} model=gemini-2.0-flash attempt=#{retry_count + 1}"
      chat = RubyLLM.chat(model: "gemini-2.0-flash")
      response = chat.ask(prompt)

      # Parse the response
      text = response.content
      answer.persona = text[/PERSONA:\s*(.+?)(?=STYLE:|$)/m, 1]&.strip
      answer.style = text[/STYLE:\s*(.+?)(?=COLOURS:|$)/m, 1]&.strip
      answer.colour_palette = text[/COLOURS:\s*(.+?)(?=BRANDS:|$)/m, 1]&.strip
      answer.recommended_brands = text[/BRANDS:\s*(.+?)(?=SHOPS:|$)/m, 1]&.strip
      answer.where_to_shop = text[/SHOPS:\s*(.+?)$/m, 1]&.strip

      # return true
      answer.save
      Rails.logger.info "AI request success fashion_answer_id=#{answer.id}"
      true
    rescue => e
      retry_count += 1
      if retry_count <= max_retries
        delay = base_delay * (2 ** (retry_count - 1)) + rand(0..2) # 3s, 6s, 12s, 24s, 48s + jitter
        Rails.logger.warn "AI error (#{e.class}: #{e.message}), retrying in #{delay}s (attempt #{retry_count}/#{max_retries}) fashion_answer_id=#{answer.id}"
        sleep(delay)
        retry
      else
        Rails.logger.error "AI giving up: #{e.class}: #{e.message} fashion_answer_id=#{answer.id} after #{retry_count} attempts"
        false
      end
    end
  end
end
