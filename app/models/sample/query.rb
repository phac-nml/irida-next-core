# frozen_string_literal: true

# model to represent sample search form
class Sample::Query # rubocop:disable Style/ClassAndModuleChildren, Metrics/ClassLength
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Pagy::Backend

  ResultTypeError = Class.new(StandardError)

  attribute :column, :string
  attribute :direction, :string
  attribute :name_or_puid_cont, :string
  attribute :name_or_puid_in, default: -> { [] }
  attribute :project_ids, default: -> { [] }
  attribute :groups, default: -> { [] }
  attribute :sort, :string, default: 'updated_at desc'
  attribute :advanced_query, :boolean, default: false

  validates :direction, inclusion: { in: %w[asc desc] }
  validates :project_ids, length: { minimum: 1 }

  def initialize(...)
    super
    self.sort = sort
    self.advanced_query = advanced_query?
  end

  def groups_attributes=(attributes)
    @groups ||= []
    attributes.each_value do |group_attributes|
      conditions ||= []
      group_attributes.each_value do |conditions_attributes|
        conditions_attributes.each_value do |condition_params|
          conditions.push(Sample::Condition.new(condition_params))
        end
      end
      @groups.push(Sample::Group.new(conditions:))
    end
  end

  def sort=(value)
    super
    column, direction = sort.split
    column = column.gsub('metadata_', 'metadata.') if column.match?(/metadata_/)
    assign_attributes(column:, direction:)
  end

  def advanced_query?
    return !@groups.empty? if @groups

    false
  end

  def results(**results_arguments)
    if results_arguments[:limit] || results_arguments[:page]
      pagy_results(results_arguments[:limit], results_arguments[:page])
    else
      advanced_query ? searchkick_results : ransack_results
    end
  end

  private

  def pagy_results(limit, page)
    if advanced_query
      pagy_searchkick(searchkick_pagy_results, limit:, page:)
    else
      pagy(ransack_results, limit:, page:)
    end
  end

  def ransack_results
    return Sample.none unless valid?

    sort_samples.ransack(ransack_params).result
  end

  def searchkick_pagy_results
    return Sample.pagy_search('') unless valid?

    Sample.pagy_search(name_or_puid_cont.presence || '*', **searchkick_kwargs)
  end

  def searchkick_results
    return Sample.search('') unless valid?

    Sample.search(name_or_puid_cont.presence || '*', **searchkick_kwargs)
  end

  def searchkick_kwargs
    { fields: [{ name: :text_middle }, { puid: :text_middle }],
      misspellings: false,
      where: { project_id: project_ids }.merge((
       if name_or_puid_in.present?
         { _or: [{ name: name_or_puid_in },
                 { puid: name_or_puid_in }] }
       else
         {}
       end
     )).merge(advanced_search_params),
      order: { "#{column}": { order: direction, unmapped_type: 'long' } },
      includes: [project: { namespace: [{ parent: :route }, :route] }] }
  end

  def advanced_search_params # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    hash = {}
    @groups.first.conditions.map do |condition|
      case condition.operator
      when '='
        hash[condition.field] = condition.value
      when '!='
        hash[condition.field] = { not: condition.value }
      when '<='
        if condition.field.end_with?('_date')
          hash[condition.field] = { lte: condition.value }
        else
          hash["#{condition.field}.numeric"] = { lte: condition.value.to_i }
        end
      when '>='
        if condition.field.end_with?('_date')
          hash[condition.field] = { gte: condition.value }
        else
          hash["#{condition.field}.numeric"] = { gte: condition.value.to_i }
        end
      when 'contains'
        hash[condition.field] = { like: condition.value }
      end
    end
    hash
  end

  def ransack_params
    {
      name_or_puid_cont: name_or_puid_cont,
      name_or_puid_in: name_or_puid_in
    }.compact
  end

  def sort_samples(scope = Sample.where(project_id: project_ids))
    if column.starts_with? 'metadata.'
      field = column.gsub('metadata.', '')
      scope.order(Sample.metadata_sort(field, direction))
    else
      scope.order("#{column} #{direction}")
    end
  end
end
