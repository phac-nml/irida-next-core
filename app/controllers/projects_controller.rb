# frozen_string_literal: true

# Controller actions for Projects
class ProjectsController < ApplicationController
  before_action :project, only: %i[show edit update activity transfer]
  before_action :namespace, only: %i[new create]

  def index
    @projects = Project.all
  end

  def show
    # No necessary code here
  end

  def new
    @new_project = Project.new
  end

  def edit
    respond_to do |format|
      format.html do
        render 'edit'
      end
    end
  end

  def create
    namespace_attributes = if project_params[:namespace_attributes][:parent_id]
                             project_params[:namespace_attributes]
                           else
                             project_params[:namespace_attributes].merge(parent_id: @namespace.id)
                           end
    @project = Projects::CreateService.new(current_user, project_params.merge(namespace_attributes:)).execute

    if @project.persisted?
      redirect_to(
        project_path(@project),
        notice: t('.success', project_name: @project.name)
      )
    else
      render 'new'
    end
  end

  def update
    if Projects::UpdateService.new(@project, current_user, project_params).execute
      redirect_to(
        project_path(@project),
        notice: t('.success', project_name: @project.name)
      )
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def activity
    respond_to do |format|
      format.html do
        render 'activity'
      end
    end
  end

  def transfer
    new_namespace ||= Namespace.find(params.require(:new_namespace_id))
    if Projects::TransferService.new(@project, current_user).execute(new_namespace)
      redirect_to(
        project_path(@project),
        notice: t('.success', project_name: @project.name)
      )
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def project_params
    params.require(:project)
          .permit(project_params_attributes)
  end

  def namespace_attributes
    %i[
      name
      path
      description
      parent_id
    ]
  end

  def project_params_attributes
    [
      namespace_attributes:
    ]
  end

  def project
    return unless params[:project_id] || params[:id]

    path = [params[:namespace_id], params[:project_id] || params[:id]].join('/')
    @project ||= Namespaces::ProjectNamespace.find_by_full_path(path).project # rubocop:disable Rails/DynamicFindBy
  end

  def namespace
    @group = Group.find_by(id: params[:namespace_id] || params[:group_id])
    @namespace = @group
  end
end
