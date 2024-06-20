# frozen_string_literal: true

# Common share actions
module ShareActions # rubocop:disable Metrics/ModuleLength
  extend ActiveSupport::Concern

  included do
    before_action proc { namespace }
    before_action proc { access_levels }
    before_action proc { namespace_group_link }, only: %i[destroy update]
    before_action proc { tab }, only: %i[index new create]
    before_action proc { namespace_linkable_groups }, only: %i[new create]
  end

  def index
    respond_to do |format|
      format.turbo_stream do
        @pagy, @namespace_group_links = pagy(load_namespace_group_links)
      end
    end
  end

  def new
    @new_group_link = NamespaceGroupLink.new(namespace_id: @namespace.id)
  end

  def create # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @created_namespace_group_link = GroupLinks::GroupLinkService.new(current_user, @namespace,
                                                                     group_link_params).execute
    @pagy, @namespace_group_links = pagy(load_namespace_group_links)

    if @created_namespace_group_link.persisted?
      respond_to do |format|
        @group_invited = true
        format.turbo_stream do
          render status: :ok,
                 locals: { namespace_group_link: @created_namespace_group_link,
                           access_levels: @access_levels,
                           type: 'success',
                           message: t('.success',
                                      namespace_name: @created_namespace_group_link.namespace.human_name,
                                      group_name: @created_namespace_group_link.group.human_name) }
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render status: :unprocessable_entity,
                 locals: { namespace_group_link: @created_namespace_group_link,
                           type: 'alert',
                           message: @created_namespace_group_link.errors.full_messages.first }
        end
      end
    end
  end

  def destroy # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    GroupLinks::GroupUnlinkService.new(current_user, @namespace_group_link).execute
    @pagy, @namespace_group_links = pagy(load_namespace_group_links)

    respond_to do |format|
      if @namespace_group_link
        if @namespace_group_link.deleted?
          format.turbo_stream do
            render status: :ok, locals: { namespace_group_link: @namespace_group_link, type: 'success',
                                          message: t('.success', namespace_name: @namespace.human_name,
                                                                 group_name: @namespace_group_link.group.human_name) }
          end
        else
          format.turbo_stream do
            render status: :unprocessable_entity,
                   locals: { namespace_group_link: @namespace_group_link, type: 'alert',
                             message: @namespace_group_link.errors.full_messages.first }
          end
        end
      else
        format.turbo_stream do
          render status: :bad_request,
                 locals: { type: 'alert',
                           message: t('error') }
        end
      end
    end
  end

  def update # rubocop:disable Metrics/MethodLength
    @updated = GroupLinks::GroupLinkUpdateService.new(current_user, @namespace_group_link, group_link_params).execute
    updated_param = if group_link_params[:group_access_level].nil?
                      t('.params.expiration_date')
                    else
                      t('.params.group_access_level')
                    end

    respond_to do |format|
      if @updated
        format.turbo_stream do
          render status: :ok, locals: { namespace_group_link: @namespace_group_link,
                                        access_levels: @access_levels,
                                        type: 'success',
                                        message: t('.success', namespace_name: @namespace.human_name,
                                                               group_name: @namespace_group_link.group.human_name,
                                                               param_name: updated_param) }
        end
      else
        format.turbo_stream do
          render status: :unprocessable_entity,
                 locals: { namespace_group_link: @namespace_group_link, type: 'alert',
                           message: t('.error') }
        end
      end
    end
  end

  def tab
    @tab = params[:tab]
  end

  protected

  def group_links_path
    raise NotImplementedError
  end

  def group_link_namespace
    raise NotImplementedError
  end

  private

  def access_levels
    @access_levels = Member::AccessLevel.access_level_options_for_user(@namespace, current_user)
  end

  def namespace_linkable_groups
    @namespace_linkable_groups = Group.where.not(
      id: NamespaceGroupLink.where(namespace:).select(:group_id) + Group.where(id: namespace.id).select(:id)
    )
  end

  def load_namespace_group_links
    authorized_scope(NamespaceGroupLink, type: :relation,
                                         scope_options: { namespace: @namespace })
  end
end
