RubyLLM.configure do |config|
  config.gemini_api_key = ENV["GEMINI_API_KEY"]
  config.openai_api_key = ENV["OPENAI_API_KEY"]
  config.logger = Rails.logger
end
