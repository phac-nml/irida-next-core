module Activities
  module Groups
    module Projects
      # Component for rendering a subgroup transferred out of a group project activity
      class CrudActivityComponent < Component
        def initialize(activity: nil)
          @activity = activity
        end

        def project_exists
          return false if @activity[:project].nil?

          !@activity[:project].deleted?
        end
      end
    end
  end
end
