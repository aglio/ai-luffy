class ChatRecordsController < ApplicationController
  def create
    @chat_record = Chat.find(params[:chat_record_id])
    @chat_record.ask(params[:message])

    respond_to do |format|
      format.turbo_stream
      format.html { render "home/index" }
    end
  end
end
