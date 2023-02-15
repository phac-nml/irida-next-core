# frozen_string_literal: true

# Validator for path attribute in Namespaces
class NamespacePathValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ self.class.format_regex
      record.errors.add(attribute, self.class.format_error_message)
      return
    end

    full_path = record.build_full_path
    return unless full_path

    return if self.class.valid_path?(full_path)

    record.errors.add(attribute, "#{value} is a reserved name")
  end

  def self.path_regex
    Irida::PathRegex.full_namespace_path_regex
  end

  def self.format_regex
    Irida::PathRegex.namespace_format_regex
  end

  def self.format_error_message
    'Namespace Path is not valid'
  end

  def self.valid_path?(path)
    "#{path}/" =~ path_regex
  end
end
