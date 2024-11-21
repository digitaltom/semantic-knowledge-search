Rails.application.config.after_initialize do
  Llm::Api.create.inspect
end
