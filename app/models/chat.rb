class Chat < ApplicationRecord
  acts_as_chat

  belongs_to :user, optional: true
  validates :model_id, presence: true

  after_initialize :set_chat

  def set_chat
    @chat = RubyLLM.chat(model: model_id, provider: "openai")
  end
end
