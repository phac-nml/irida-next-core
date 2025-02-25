# frozen_string_literal: true

require 'test_helper'
require 'tempfile'
require 'csv'

class ExcelHelperTest < ActionView::TestCase
  include ExcelHelper

  test 'raises error when no file is provided' do
    assert_raises(ExcelParsingError, 'No file provided') do
      parse_excel_file(nil)
    end
  end

  test 'raises error when headers are missing in CSV file' do
    file = Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/excel_helper_test/missing_headers.csv'))
    blob = ActiveStorage::Blob.create_and_upload!(
      io: file,
      filename: file.original_filename,
      content_type: file.content_type
    )
    assert_raises(ExcelParsingError, 'No headers found in file') do
      parse_excel_file(blob)
    end
  end

  test 'successfully parses CSV file with valid data' do
    file = Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/excel_helper_test/good_csv.csv'))
    blob = ActiveStorage::Blob.create_and_upload!(
      io: file,
      filename: file.original_filename,
      content_type: file.content_type
    )
    result = parse_excel_file(blob)

    assert_equal 3, result.length
    assert_equal %w[name age city], result[0]
    assert_equal({ 'name' => 'Alice', 'age' => 30, 'city' => 'New York' }, result[1])
    assert_equal({ 'name' => 'Bob', 'age' => 25, 'city' => 'London' }, result[2])
  end

  test 'skips empty rows in data' do
    file = Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/excel_helper_test/missing_rows.csv'))
    blob = ActiveStorage::Blob.create_and_upload!(
      io: file,
      filename: file.original_filename,
      content_type: file.content_type
    )
    result = parse_excel_file(blob)

    assert_equal 3, result.length # headers + 2 data rows
    assert_equal %w[name age], result[0]
  end

  test 'handles rows with incorrect number of columns' do
    file = Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/excel_helper_test/incorrect_cols.csv'))
    blob = ActiveStorage::Blob.create_and_upload!(
      io: file,
      filename: file.original_filename,
      content_type: file.content_type
    )
    result = parse_excel_file(blob)

    assert_equal 2, result.length # Only headers and the valid row
    assert_equal %w[name age city], result[0]
    assert_equal({ 'name' => 'Bob', 'age' => 25, 'city' => 'London' }, result[1])
  end

  test 'raises error for unsupported file format' do
    file = Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/excel_helper_test/unsupported.txt'))
    blob = ActiveStorage::Blob.create_and_upload!(
      io: file,
      filename: file.original_filename,
      content_type: file.content_type
    )

    error = assert_raises(ExcelParsingError) do
      parse_excel_file(blob)
    end
    assert_match('An unexpected error occurred while parsing the file', error.message)
  end
end
