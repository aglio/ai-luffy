class Chat < ApplicationRecord
  acts_as_chat

  belongs_to :user, optional: true
  validates :model_id, presence: true

  after_initialize :set_chat_client

  attr_reader :chat_client

  def set_chat_client
    @chat_client = RubyLLM.chat(model: model_id, provider: "openai")
  end
end
