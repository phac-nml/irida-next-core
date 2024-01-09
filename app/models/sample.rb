# frozen_string_literal: true

# entity class for Sample
class Sample < ApplicationRecord
  has_logidze
  acts_as_paranoid

  belongs_to :project

  has_many :attachments, as: :attachable, dependent: :destroy

  has_many :samples_workflow_executions, dependent: :nullify
  has_many :workflow_executions, through: :samples_workflow_executions

  validates :name, presence: true, length: { minimum: 3, maximum: 255 }
  validates :name, uniqueness: { scope: %i[name project_id] }

  def self.ransackable_scopes(_auth_object = nil)
    %i[search]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[]
  end

  def self.search(term)
    metadata_text = Arel::Nodes::NamedFunction.new('CAST',
                                                   [Sample.arel_table[:metadata]
                                                   .as(Arel::Nodes::SqlLiteral.new('Text'))])

    metadata_search = metadata_text.matches("%#{term}%")
    name_search = Sample.arel_table[:name].matches("%#{term}%")

    where(metadata_search.or(name_search))
  end
end
