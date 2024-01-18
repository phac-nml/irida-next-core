# frozen_string_literal: true

require 'test_helper'

module Projects
  module Samples
    module Metadata
      class FileImportControllerTest < ActionDispatch::IntegrationTest
        setup do
          sign_in users(:john_doe)
          @namespace = groups(:group_one)
          @project = projects(:project1)
          @csv = fixture_file_upload('test/fixtures/files/metadata/valid.csv')
        end

        # bin/rails test test/controllers/projects/samples/metadata/file_import_controller_test.rb

        test 'import sample metadata with permission' do
          post namespace_project_samples_file_import_path(@namespace, @project),
               params: {
                 file_import: {
                   file: @csv,
                   sample_id_column: 'sample_name'
                 }
               }

          assert_response :success
        end

        test 'import sample metadata without permission' do
          login_as users(:micha_doe)

          post namespace_project_samples_file_import_path(@namespace, @project),
               params: {
                 file_import: {
                   file: @csv,
                   sample_id_column: 'sample_name'
                 }
               }

          assert_response :unauthorized
        end

        test 'import sample metadata with invalid file' do
          other = File.new('test/fixtures/files/metadata/invalid.txt', 'r')
          post namespace_project_samples_file_import_path(@namespace, @project),
               params: {
                 file_import: {
                   file: other,
                   sample_id_column: 'sample_name'
                 }
               }

          assert_response :unprocessable_entity
        end
      end
    end
  end
end
