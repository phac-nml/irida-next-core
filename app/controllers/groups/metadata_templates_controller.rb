# frozen_string_literal: true

module Groups
  # Controller actions for Metadata Templates
  class MetadataTemplatesController < Groups::ApplicationController
    include MetadataTemplateActions

    before_action :current_page

    private

    def metadata_template_params
      params.require(:metadata_template).permit(:name, fields: [])
    end

    protected

    def namespace
      @group ||= Group.find_by_full_path(request.params[:group_id]) # rubocop:disable Rails/DynamicFindBy
      @namespace = @group
    end

    def metadata_templates_path
      group_metadata_templates_path
    end

    def current_page
      @current_page = t(:'groups.sidebar.metadata_templates')
    end
  end
end
