# frozen_string_literal: true

module Groups
  # Service used to Delete Groups
  class DestroyService < BaseService
    attr_accessor :group

    def initialize(group, user = nil, params = {})
      super(user, params.except(:group, :group_id))
      @group = group
    end

    def execute
      if group.owners.include?(current_user)
        group.destroy
      else
        group.errors.add(:base, 'You are not authorized to delete this group.')
      end
    end
  end
end
