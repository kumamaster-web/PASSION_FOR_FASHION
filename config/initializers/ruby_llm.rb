RubyLLM.configure do |config|
  config.gemini_api_key = ENV["GEMINI_API_KEY"]
  config.openai_api_key = ENV["OPENAI_API_KEY"]
  config.logger = Rails.logger

  # Generous timeout: wait up to 120s for a response
  config.request_timeout = 120

  # Built-in HTTP-level retries (covers timeouts, 5xx, connection resets)
  config.max_retries = 5
  config.retry_interval = 1          # start at 1s
  config.retry_backoff_factor = 2     # 1s, 2s, 4s, 8s, 16s
  config.retry_interval_randomness = 0.5
end
