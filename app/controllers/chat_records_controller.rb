class ChatRecordsController < ApplicationController
  def create
    @chat_record = Chat.find(params[:chat_record_id])

    # Save user's message
    user_message = @chat_record.messages.create!(role: "user", content: params[:message])

    # Create a placeholder for the assistant's message
    assistant_message = @chat_record.messages.create!(role: "assistant", content: "")

    respond_to do |format|
      format.turbo_stream do |turbo_stream|
        # Append the user's message immediately
        turbo_stream.append "message_history", partial: "messages/message", locals: { message: user_message }

        # Append the initial assistant placeholder
        turbo_stream.append "message_history", partial: "messages/message", locals: { message: assistant_message }

        # Stream the response from rubyllm
        full_content = ""
        @chat_record.chat_client.ask(params[:message], stream: true) do |chunk|
          full_content += chunk.content
          # Update the assistant's message in real-time
          turbo_stream.replace assistant_message, partial: "messages/message", locals: { message: assistant_message.tap { |m| m.content = full_content } }
        end

        # Save the final content to the assistant's message
        assistant_message.update!(content: full_content)

        # Reset the form
        turbo_stream.update "message_form", partial: "chat_records/form", locals: { chat_record: @chat_record }
      end
      format.html { redirect_to root_path } # Fallback for non-Turbo requests
    end
  end
end

