# frozen_string_literal: true

module Nextflow
  module Samplesheet
    # Component to render a row in the sample sheet
    class RowComponent < Component
      attr_reader :sample, :files, :properties

      def initialize(sample, index, properties, required_properties)
        @sample = sample
        @index = index
        @properties = format_properties(properties)
        @required_properties = required_properties
        @files = sort_files
      end

      def format_properties(properties)
        properties.map do |name, entry|
          entry['is_fastq'] = name.match(/fastq_\d+/)
          next unless check_for_file(entry)

          entry['pattern'] = entry['pattern'] || entry['anyOf'].select do |e|
            e.key?('format') && e['format'] == 'file-path'
          end.pluck('pattern').join('|')
        end
        properties
      end

      def sort_files
        singles = []
        pe_forward = []
        pe_reverse = []

        @sample.attachments.each do |attachment|
          item = [attachment.file.filename.to_s, attachment.to_global_id, { 'data-puid': attachment.puid }]
          case attachment.metadata['direction']
          when nil
            singles << item
          when 'forward'
            pe_forward << item
          else
            pe_reverse << item
          end
        end

        { singles:, pe_forward:, pe_reverse: }
      end

      def render_cell_type(property, entry, sample, fields)
        return render_sample_cell(sample, fields) if property == 'sample'

        return render_metadata_cell(sample, property, entry, fields) if entry['meta'].present?

        return render_fastq_cell(property, entry, fields) if entry['is_fastq']

        return render_other_file_cell(property, entry, fields) if check_for_file(entry)

        return render_dropdown_cell(property, entry, fields) if entry['enum'].present?

        render_input_cell(property, fields)
      end

      def render_fastq_cell(property, entry, fields)
        index = property.match(/fastq_(\d+)/)[1].to_i - 1
        files = index.zero? ? @files[:pe_forward] : @files[:pe_reverse]
        render_file_cell(property, entry, fields, files,
                         @required_properties.include?(property))
      end

      def render_other_file_cell(property, entry, fields)
        files = if entry['pattern']
                  filter_files_by_pattern(@files[:singles], entry['pattern'])
                else
                  @files[:singles]
                end
        render_file_cell(property, entry, fields,
                         files, @required_properties.include?(property))
      end

      def filter_files_by_pattern(files, pattern)
        files.select { |file| file.first[Regexp.new(pattern)] }
      end

      def render_sample_cell(sample, fields)
        render(Samplesheet::SampleCellComponent.new(sample:, fields:))
      end

      def render_metadata_cell(sample, name, entry, fields)
        render(Samplesheet::MetadataCellComponent.new(sample:, name:, entry:, form: fields))
      end

      def render_file_cell(property, entry, fields, files, is_required)
        data = if entry['is_fastq']
                 {
                   'data-action' => 'change->nextflow--samplesheet#file_selected',
                   'data-nextflow--samplesheet-target' => 'select'
                 }
               else
                 {}
               end
        render(Samplesheet::DropdownCellComponent.new(
                 property,
                 files,
                 fields,
                 is_required,
                 data
               ))
      end

      def render_dropdown_cell(property, entry, fields)
        render(Samplesheet::DropdownCellComponent.new(
                 property,
                 entry['enum'],
                 fields,
                 @required_properties.include?(property)
               ))
      end

      def render_input_cell(property, fields)
        render(Samplesheet::TextCellComponent.new(
                 property,
                 fields:
               ))
      end

      def check_for_file(entry)
        entry['is_fastq'] || entry['format'] == 'file-path' || (entry.key?('anyOf') && entry['anyOf'].any? do |e|
          e['format'] == 'file-path'
        end)
      end
    end
  end
end
