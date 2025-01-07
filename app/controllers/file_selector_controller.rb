# frozen_string_literal: true

# Controller actions for Projects
class FileSelectorController < ApplicationController
  before_action :attachable, only: %i[new create]
  before_action :attachments, only: %i[create]
  before_action :listing_attachments, only: %i[new create]

  def new
    render turbo_stream: turbo_stream.update('file_selector_dialog',
                                               partial: 'file_selector/file_selector_dialog',
                                               locals: {file_selector_params:, open: true}), status: :ok
  end

  def create
    respond_to do |format|
      format.turbo_stream do
        render status: :ok, locals: {file_selector_params:}
      end
    end
  end

  private

  def file_selector_params
    params.require(:file_selector).permit(
      :attachable, :index, :property, :selected_id, :file_type, required_properties: [],
      file_selector_arguments: [:pattern, workflow_params: [:name, :version]]
    )
  end

  def listing_attachments
    if file_selector_params['file_type'] == 'fastq'
    @listing_attachments = @attachable.samplesheet_fastq_files(file_selector_params["property"], file_selector_params['file_selector_arguments']["workflow_params"])
    elsif file_selector_params['file_type'] == 'other'
      @listing_attachments = if file_selector_params['file_selector_arguments']['pattern']
        @attachable.filter_files_by_pattern(@attachable.sorted_files[:singles] || [], file_selector_params['file_selector_arguments']['pattern'])
      else
        sample.sorted_files[:singles] || []
      end
    end

    @listing_attachments = @listing_attachments.sort_by {|file| file[:created_at]}.reverse
  end

  def attachable
    @attachable = Sample.find(file_selector_params[:attachable])
  end

  def attachments
    @attachment_params = {}
    return if params[:attachment_id] == 'no_attachment'

    attachment = Attachment.find(params[:attachment_id])
    @attachment_params = { filename: attachment.file.filename.to_s,
      global_id: attachment.to_global_id,
      id: attachment.id,
      byte_size: attachment.byte_size,
      created_at: attachment.created_at
    }
    return unless attachment.associated_attachment &&
    (file_selector_params["property"] == 'fastq_1' || file_selector_params["property"] == 'fastq_2')

    assign_associated_attachment_params(attachment)
  end

  def assign_associated_attachment_params(attachment)
    @associated_attachment_params = {}
    associated_attachment = attachment.associated_attachment

    @associated_attachment_params[:file] = {filename: associated_attachment.filename.to_s, global_id: associated_attachment.to_global_id, id: associated_attachment.id}
    @associated_attachment_params[:property] = file_selector_params[:property] == "fastq_1" ? "fastq_2" : "fastq_1"
    @associated_attachment_params[:file_selector_arguments] = {}
    @associated_attachment_params[:file_selector_arguments][:workflow_params] = file_selector_params['file_selector_arguments']["workflow_params"]
  end
end
