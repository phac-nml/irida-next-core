# frozen_string_literal: true

module Irida
  # Module to store pipeline values
  module Pipeline
    module_function

    def init(id, entry, version, schema_loc)
      workflow = Struct.new(:name, :id, :description, :version, :metadata, :type, :type_version, :engine,
                            :engine_version, :url, :execute_loc, :schema_loc)

      name = entry['name']
      description = entry['description']
      metadata = { workflow_name: name, workflow_version: version }
      type = nil
      type_version = nil
      engine = nil
      engine_version = nil
      url = entry['url']
      execute_loc = 'azure'
      # schema_loc = 'test/fixtures/files/nextflow/nextflow_schema.json'

      @workflow = workflow.new(name, id, description, version, metadata, type, type_version, engine, engine_version,
                               url, execute_loc, schema_loc)

      @workflow
    end
  end
end
