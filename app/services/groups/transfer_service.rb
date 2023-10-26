# frozen_string_literal: true

module Groups
  # Service used to Transfer Groups
  class TransferService < BaseGroupService
    TransferError = Class.new(StandardError)

    def execute(new_namespace) # rubocop:disable Metrics/AbcSize
      validate(new_namespace)

      # Authorize if user can transfer group
      authorize! @group, to: :transfer?

      # Authorize if user can transfer group into namespace
      authorize! new_namespace, to: :transfer_into_namespace?

      if Group.where(parent_id: new_namespace.id).exists?(['path = ? or name = ?', @group.path,
                                                           @group.name])
        raise TransferError, I18n.t('services.groups.transfer.namespace_group_exists')
      end

      group_ancestor_members_user_ids = Member.for_namespace_and_ancestors(@group).select(:user_id).pluck(:user_id)
      update_members = Member.for_namespace_and_ancestors(new_namespace).where(user_id: group_ancestor_members_user_ids)

      @group.update(parent_id: new_namespace.id)

      update_members.each(&:update_descendant_memberships)

      true
    rescue Groups::TransferService::TransferError => e
      @group.errors.add(:new_namespace, e.message)
      false
    end

    private

    def validate(new_namespace)
      raise TransferError, I18n.t('services.groups.transfer.namespace_empty') if new_namespace.blank?

      return unless new_namespace.id == @group.id

      raise TransferError,
            I18n.t('services.groups.transfer.same_group_and_namespace')
    end
  end
end
