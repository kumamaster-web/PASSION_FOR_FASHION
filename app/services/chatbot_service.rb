# app/services/chatbot_service.rb
require "ruby_llm"

class ChatbotService
  def initialize(chat:)
    @chat = chat
    @fa = chat.fashion_answer
  end

  def reply!(last_user_message:)
    max_retries = 5
    retry_count = 0
    base_delay = 3 # seconds

    begin
      Rails.logger.info "ChatbotService request start chat_id=#{@chat.id} attempt=#{retry_count + 1}"
      llm = RubyLLM.chat(model: "gemini-2.0-flash")

      # System context (quiz-specific)
      llm.add_message(role: :user, content: system_context)

      # Conversation history from DB
      @chat.messages.order(:created_at).each do |m|
        role = (m.role == "assistant") ? :assistant : :user
        llm.add_message(role: role, content: m.content)
      end

      # Ask (use the latest user message)
      response = llm.ask(last_user_message)
      Rails.logger.info "ChatbotService request success chat_id=#{@chat.id}"
      response.content
    rescue => e
      retry_count += 1
      if retry_count <= max_retries
        delay = base_delay * (2 ** (retry_count - 1)) + rand(0..2)
        Rails.logger.warn "ChatbotService error (#{e.class}: #{e.message}), retrying in #{delay}s (attempt #{retry_count}/#{max_retries}) chat_id=#{@chat.id}"
        sleep(delay)
        retry
      end

      Rails.logger.error "ChatbotService giving up: #{e.class}: #{e.message} chat_id=#{@chat.id} after #{retry_count} attempts"
      "Sorry - I couldn't reach the AI right now. Please try again."
    end
  end

  private

  def system_context
    <<~PROMPT
      You are an AI fashion stylist for PASSION_FOR_FASHION.
      ALWAYS base your advice on this specific quiz result.

      Gender: #{@fa.gender}
      Budget: #{@fa.price_min}-#{@fa.price_max} #{@fa.currency}

      Lifestyle: #{@fa.lifestyle}
      Favorite Colors: #{@fa.colors}
      Main Occasion: #{@fa.occasion}
      Comfort Preference: #{@fa.comfort}
      Style Statement: #{@fa.statement}
      Personality Type: #{@fa.personality_type}

      Generated Recommendations:
      Persona: #{@fa.persona}
      Style: #{@fa.style}
      Colour palette: #{@fa.colour_palette}
      Brands: #{@fa.recommended_brands}
      Shops: #{@fa.where_to_shop}

      Rules:
      - Be practical and specific.
      - Give outfit ideas in bullet points.
      - Ask at most ONE clarifying question if needed.
    PROMPT
  end
end
