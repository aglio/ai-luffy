RubyLLM.configure do |config|
  config.openai_api_key = Rails.application.credentials.openai.secret_key
end