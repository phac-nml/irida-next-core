# frozen_string_literal: true

module Activities
  # Component for rendering an activity list item
  class ListItemComponent < Component
    attr_accessor :activity

    def initialize(activity: nil, **system_arguments)
      @activity = activity

      @system_arguments = system_arguments
    end
  end
end