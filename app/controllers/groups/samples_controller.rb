# frozen_string_literal: true

module Groups
  # Controller actions for Samples within a Group
  class SamplesController < Groups::ApplicationController
    include Metadata
    include Storable

    before_action :group, :current_page
    before_action :query, only: %i[index search select]
    before_action :metadata_templates, only: %i[index search select]

    def index
      @timestamp = DateTime.current
      @pagy, @samples = @query.results(limit: params[:limit] || 20, page: params[:page] || 1)
      @has_samples = @group.has_samples?
    end

    def search
      respond_to do |format|
        format.turbo_stream do
          if @query.valid?
            render status: :ok
          else
            render status: :unprocessable_entity
          end
        end
      end
    end

    def select
      authorize! @group, to: :sample_listing?
      @sample_ids = []

      respond_to do |format|
        format.turbo_stream do
          if params[:select].present?
            @sample_ids = @query.results.where(updated_at: ..params[:timestamp].to_datetime).select(:id).pluck(:id)
          end
        end
      end
    end

    private

    def group
      @group = Group.find_by_full_path(params[:group_id]) # rubocop:disable Rails/DynamicFindBy
    end

    def authorized_samples
      authorized_scope(Sample, type: :relation, as: :namespace_samples,
                               scope_options: { namespace: @group }).includes(project: { namespace: [{ parent: :route },
                                                                                                     :route] })
    end

    def layout_fixed
      super
      return unless action_name == 'index'

      @fixed = false
    end

    def context_crumbs
      super
      case action_name
      when 'index'
        @context_crumbs += [{
          name: I18n.t('groups.samples.index.title'),
          path: group_samples_path
        }]
      end
    end

    def current_page
      @current_page = t(:'groups.sidebar.samples')
    end

    def metadata_fields(template)
      fields_for_namespace_or_template(namespace: @group, template:)
    end

    def query
      authorize! @group, to: :sample_listing?

      @search_params = search_params
      metadata_fields(@search_params['metadata_template'])
      advanced_search_fields(@group)

      project_ids =
        authorized_scope(Project, type: :relation, as: :group_projects, scope_options: { group: @group }).pluck(:id)

      @query = Sample::Query.new(@search_params.except(:metadata).merge({ project_ids: project_ids }))
    end

    def search_params
      updated_params = update_store(search_key, params[:q].present? ? params[:q].to_unsafe_h : {})

      if !updated_params.key?(:sort) ||
         (updated_params[:metadata_template] == 'none' && updated_params[:sort]&.match?(/metadata_/))
        updated_params[:sort] = 'updated_at desc'
        update_store(search_key, updated_params)
      end
      updated_params
    end

    def search_key
      :"#{controller_name}_#{group.id}_search_params"
    end

    def metadata_templates
      @metadata_templates = metadata_templates_for_namespace(namespace: @group)
    end
  end
end
