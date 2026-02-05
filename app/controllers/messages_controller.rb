class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat

  def create
    user_text = message_params[:content]

    # 1) Save user message
    @chat.messages.create!(role: "user", content: user_text)

    # 2) Ask the LLM
    assistant_text = ChatbotService.new(chat: @chat).reply!(last_user_message: user_text)

    # 3) Save assistant message
    @chat.messages.create!(role: "assistant", content: assistant_text)

    # 4) Update UI with Turbo (no page reload), or fallback to HTML redirect
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to chat_path(@chat) }
    end
  end

  private

  def set_chat
    @chat = current_user.chats.find(params[:chat_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
