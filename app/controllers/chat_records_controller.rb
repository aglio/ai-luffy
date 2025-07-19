class ChatRecordsController < ApplicationController
  def create
    @chat_record = Chat.find(params[:chat_record_id])

    # Save user's message
    user_message = @chat_record.messages.create!(role: "user", content: params[:message])

    # Create a placeholder for the assistant's message
    assistant_message = @chat_record.messages.create!(role: "assistant", content: "")

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append("message_history", partial: "messages/message", locals: { message: user_message }),
          turbo_stream.append("message_history", partial: "messages/message", locals: { message: assistant_message }),
          turbo_stream.update("message_form", partial: "chat_records/form", locals: { chat_record: @chat_record })
        ]
        
        # Queue the streaming job
        ChatStreamJob.perform_later(@chat_record.id, params[:message], assistant_message.id)
      end
      format.html { redirect_to root_path } # Fallback for non-Turbo requests
    end
  end
end

