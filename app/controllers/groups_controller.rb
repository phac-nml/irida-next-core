# frozen_string_literal: true

# Controller actions for Groups
class GroupsController < ApplicationController
  layout 'groups'
  before_action :group, only: %i[edit show destroy]

  def index
    @groups = Group.all
  end

  def show
    respond_to do |format|
      format.html do
        render 'groups/show'
      end
    end
  end

  def new
    @group = Group.new
  end

  def edit
    respond_to do |format|
      format.html do
        render 'groups/edit'
      end
    end
  end

  def create
    respond_to do |format|
      @group = Group.new(group_params.merge(owner: current_user))
      if @group.save
        flash[:success] = I18n.t('groups.create_success')
        format.html { redirect_to group_path(@group.full_path) }
      else
        format.html { render :new, status: :unprocessable_entity, locals: { group: @group } }
      end
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path
  end

  private

  def group
    @group ||= Group.find_by_full_path(request.params[:group_id] || request.params[:id]) # rubocop:disable Rails/DynamicFindBy
  end

  def group_params
    params.require(:group).permit(:name, :path, :description)
  end
end
