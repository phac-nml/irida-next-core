# frozen_string_literal: true

module Projects
  module Samples
    module Metadata
      # Controller actions for Project Samples Metadata Fields Controller
      class FieldsController < Projects::Samples::ApplicationController
        respond_to :turbo_stream

        # Validates metadata edit params and builds the expected update_service param prior to calling
        # MetadataController and the metadata update_service

        # Param is received as:
        # params: {edit_field: {old_key: new_key}, {old_value: new_value}}
        # If a field has not been changed, the old and new values will be equal.
        def update # rubocop:disable Metrics/AbcSize
          authorize! @project, to: :update_sample?
          metadata_update_params = ::Samples::Metadata::Fields::EditService.new(@project, @sample, current_user,
                                                                                edit_field_params).execute
          if metadata_update_params.empty?
            render status: :unprocessable_entity,
                   locals: { key: edit_field_params['edit_field']['key'].values[0],
                             value: edit_field_params['edit_field']['value'].values[0] }
          else
            request[:sample] = metadata_update_params
            Projects::Samples::MetadataController.dispatch(:update, request, response)
          end
        end

        private

        def edit_field_params
          params.require(:sample).permit(edit_field: {})
        end
      end
    end
  end
end
