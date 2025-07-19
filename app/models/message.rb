class Message < ApplicationRecord
  acts_as_message

  belongs_to :chat
  belongs_to :tool_call, optional: true

  validates :role, presence: true
  validates :chat, presence: true
end
