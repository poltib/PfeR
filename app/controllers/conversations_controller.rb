class ConversationsController < ApplicationController
  before_filter :authenticate_user!
  helper_method :mailbox, :conversation

  def new
    if params[:id]
      @user = User.find params[:id]
    end
  end

  def create
    recipient_username = conversation_params(:recipients).split(',')
    recipients = User.where(username: recipient_username).all

    conversation = current_user.send_message(recipients, *conversation_params(:body, :subject)).conversation
    if conversation 
      redirect_to conversation, :notice => 'Your conversation has been successfully created!'
    else
      render 'new'
    end
  end

  def reply
    current_user.reply_to_conversation(conversation, *message_params(:body))
    redirect_to conversation
  end

  def trash
    conversation.move_to_trash(current_user)
    redirect_to :conversations
  end

  def untrash
    conversation.untrash(current_user)
    redirect_to :conversations
  end

  def delete
    conversation.delete
    redirect_to :conversations
  end


  private

    def mailbox
      @mailbox ||= current_user.mailbox
    end

    def conversation
      @conversation ||= mailbox.conversations.find(params[:id])
    end

    def conversation_params(*keys)
      fetch_params(:conversation, *keys)
    end

    def message_params(*keys)
      fetch_params(:message, *keys)
    end

    def fetch_params(key, *subkeys)
      params[key].instance_eval do
        case subkeys.size
        when 0 then self
        when 1 then self[subkeys.first]
        else subkeys.map{|k| self[k] }
        end
      end
    end

end