Rails.application.config.after_initialize do
  Llm::Api.api_class.inspect
end
