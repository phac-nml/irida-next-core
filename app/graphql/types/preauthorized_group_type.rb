# frozen_string_literal: true

module Types
  # Preuthorized Group Type
  # Only to be used as a return type on fields that are connections and
  # are either scoped or come from an authorized object
  class PreuthorizedGroupType < Types::GroupType # rubocop:disable GraphQL/ObjectDescription
    def self.authorized?(_object, _context)
      true
    end
  end
end
