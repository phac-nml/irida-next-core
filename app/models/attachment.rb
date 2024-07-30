# frozen_string_literal: true

# entity class for Attachment
class Attachment < ApplicationRecord
  has_logidze
  acts_as_paranoid

  include HasPuid

  belongs_to :attachable, touch: :attachments_updated_at, polymorphic: true

  has_one_attached :file

  validates :file, attached: true

  validates_with AttachmentChecksumValidator

  after_initialize :assign_metadata

  delegate :filename, to: :file

  delegate :byte_size, to: :file

  def self.model_prefix
    'ATT'
  end

  # override destroy so that on soft delete we don't delete the ActiveStorage::Attachment
  def destroy
    update(deleted_at: Time.current)
  end

  def fastq?
    metadata['format'] == 'fastq'
  end

  def fasta?
    metadata['format'] == 'fasta'
  end

  def associated_attachment
    Attachment.find_by(attachable:, id: metadata['associated_attachment_id'])
  end

  private

  FORMAT_REGEX = {
    fasta: /^\S+\.fn?a(sta)?(\.gz)?$/,
    fastq: /^\S+\.f(ast)?q(\.gz)?$/,
    text: /^\S+\.(txt|rtf)?(\.gz)?$/,
    csv: /^\S+\.(csv)?(\.gz)?$/,
    tsv: /^\S+\.(tsv)?(\.gz)?$/,
    spreadsheet: /^\S+\.(xls|xlsx)?$/,
    json: /^\S+\.(json)?(\.gz)?$/,
    genbank: /^\S+\.(gbk|gbf|genbank)?(\.gz)?$/
  }.freeze

  def assign_metadata
    return if metadata.key? 'format'

    found_format = FORMAT_REGEX.find { |key, value| filename.to_s =~ value }

    if found_format.nil?
      metadata['format'] = 'unknown'
    else
      metadata['format'] = found_format[0].to_s
      metadata['type'] = 'assembly' if metadata['format'] == 'fasta'
    end

    metadata['compression'] = filename.to_s.match?(/^\S+(.gz)+$/) ? 'gzip' : 'none'
  end
end
