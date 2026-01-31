class FashionAnswersController < ApplicationController
  before_action :authenticate_user!

  def new
    @fashion_answer = FashionAnswer.new
  end

  def create
    @fashion_answer = current_user.fashion_answers.new(fashion_answer_params)

    # Upload image to Cloudinary
    if params[:fashion_answer][:photo].present?
      result = Cloudinary::Uploader.upload(params[:fashion_answer][:photo])
      @fashion_answer.image_path = result["secure_url"]
    end

    if @fashion_answer.save
      # Generate AI advice
      generate_advice(@fashion_answer)
      redirect_to @fashion_answer
    else
      render :new
    end
  end

  def show
    @fashion_answer = current_user.fashion_answers.find(params[:id])
  end

  def index
    @fashion_answers = current_user.fashion_answers.order(created_at: :desc)
  end

  private

  def fashion_answer_params
    params.require(:fashion_answer).permit(:lifestyle, :colors, :occasion, :comfort, :statement, :personality_type)
  end

  def generate_advice(answer)
    prompt = <<~PROMPT
      Based on the following fashion preferences, provide personalized style advice:

      Lifestyle: #{answer.lifestyle}
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

    begin
      chat = RubyLLM.chat(model: "gemini-2.0-flash-lite")
      response = chat.ask(prompt)

      # Parse the response
      text = response.content
      answer.persona = text[/PERSONA:\s*(.+?)(?=STYLE:|$)/m, 1]&.strip
      answer.style = text[/STYLE:\s*(.+?)(?=COLOURS:|$)/m, 1]&.strip
      answer.colour_palette = text[/COLOURS:\s*(.+?)(?=BRANDS:|$)/m, 1]&.strip
      answer.recommended_brands = text[/BRANDS:\s*(.+?)(?=SHOPS:|$)/m, 1]&.strip
      answer.where_to_shop = text[/SHOPS:\s*(.+?)$/m, 1]&.strip
      answer.save
    rescue => e
      Rails.logger.error "AI Error: #{e.message}"
    end
  end
end
