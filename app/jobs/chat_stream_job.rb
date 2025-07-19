class ChatStreamJob < ApplicationJob
  queue_as :default

  def perform(chat_id, message_text, assistant_message_id)
    chat = Chat.find(chat_id)
    assistant_message = Message.find(assistant_message_id)
    full_content = ""

    # Stream the response from rubyllm
    chat.chat_client.ask(message_text) do |chunk|
      # Skip if chunk.content is nil or empty
      next if chunk.content.nil? || chunk.content.empty?
      
      full_content += chunk.content
      
      # Broadcast the update
      Turbo::StreamsChannel.broadcast_replace_to(
        "chat_#{chat.id}",
        target: "message_#{assistant_message.id}",
        partial: "messages/message",
        locals: { message: assistant_message.tap { |m| m.content = full_content } }
      )
    end
    
    # Save the final content
    assistant_message.update!(content: full_content)
  rescue => e
    Rails.logger.error "ChatStreamJob error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    
    # Update message with error
    error_message = "Sorry, an error occurred while processing your request."
    assistant_message.update!(content: error_message)
    
    # Broadcast the error
    Turbo::StreamsChannel.broadcast_replace_to(
      "chat_#{chat.id}",
      target: "message_#{assistant_message.id}",
      partial: "messages/message",
      locals: { message: assistant_message }
    )
  end
end