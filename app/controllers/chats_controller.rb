class ChatsController < ApplicationController
  before_action :authenticate_user!

  def show
    @chat = current_user.chats.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    fashion_answer = current_user.fashion_answers.find(params[:fashion_answer_id])

    @chat = current_user.chats.find_or_create_by!(fashion_answer: fashion_answer) do |c|
      c.title = "AI Stylist - #{fashion_answer.created_at.strftime('%Y-%m-%d')}"
    end

    if @chat.messages.none?
      @chat.messages.create!(
        role: "assistant",
        content: "Hi! I'm your AI stylist for this quiz result. Ask me for outfits, colors, brands, or how to style for a specific occasion."
      )
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to chat_path(@chat) }
    end
  end
end
