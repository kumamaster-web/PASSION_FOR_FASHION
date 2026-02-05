# app/services/chatbot_service.rb
require "ruby_llm"

class ChatbotService
  def initialize(chat:)
    @chat = chat
    @fa = chat.fashion_answer
  end

  def reply!(last_user_message:)
    llm = RubyLLM.chat(model: "gemini-2.0-flash-lite")

    # System context (quiz-specific)
    llm.add_message(role: :user, content: system_context)

    # Conversation history from DB
    @chat.messages.order(:created_at).each do |m|
      role = (m.role == "assistant") ? :assistant : :user
      llm.add_message(role: role, content: m.content)
    end

    # Ask (use the latest user message)
    response = llm.ask(last_user_message)
    response.content
  rescue => e
    Rails.logger.error "ChatbotService AI Error: #{e.message}"
    "Sorry — I couldn’t reach the AI right now. Please try again."
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
