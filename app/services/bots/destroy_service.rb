# frozen_string_literal: true

module Bots
  # Service used to Delete Projects
  class DestroyService < BaseService
    BotAccountDestroyError = Class.new(StandardError)
    attr_accessor :bot_account, :auth_object

    def initialize(bot_account, auth_object, user = nil)
      super(user)
      @bot_account = bot_account
      @auth_object = auth_object
    end

    def execute
      authorize! auth_object, to: :destroy_bot_accounts?

      unless bot_account.email.include? @auth_object.puid
        raise BotAccountDestroyError,
              'The bot account cannot be removed as it does not belong to this project'
      end

      bot_account.destroy!
    rescue Bots::DestroyService::BotAccountDestroyError => e
      bot_account.errors.add(:base, e.message)
      false
    end
  end
end
