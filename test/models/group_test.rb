# frozen_string_literal: true

require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  def setup
    @group = groups(:group_one)
    @subgroup_one = groups(:subgroup1)
    @group_three = groups(:group_three)
  end

  test 'valid group' do
    assert @group.valid?
  end

  test 'invalid if parent is not a group' do
    @group.parent = namespaces_user_namespaces(:john_doe_namespace)
    assert_not @group.valid?
    assert_not_nil @group.errors[:parent_id]
  end

  test 'invalid if more than 9 ancestors' do
    @subgroup = groups(:subgroup10)
    assert_not @subgroup.valid?, 'subgroup is valid with more than 9 ancestors'
    assert_not_nil @subgroup.errors[:parent_id], 'no validation error for parent'
  end

  test '#ancestors' do
    assert_equal [@group], @subgroup_one.ancestors
  end

  test '#ancestor_ids' do
    assert_equal [@group.id], @subgroup_one.ancestor_ids.pluck(:id)
  end

  test '#self_and_ancestors' do
    assert_includes @subgroup_one.self_and_ancestors, @subgroup_one
    assert_includes @subgroup_one.self_and_ancestors, @group
    assert_equal 2, @subgroup_one.self_and_ancestors.count
  end

  test '#descendants' do
    assert_includes @group_three.descendants, groups(:subgroup_one_group_three)
    assert_equal 1, @group_three.descendants.count
  end

  test '#self_and_descendants' do
    assert_includes @group_three.self_and_descendants, @group_three
    assert_includes @group_three.self_and_descendants, groups(:subgroup_one_group_three)
    assert_equal 2, @group_three.self_and_descendants.count
  end

  test '#human_name' do
    assert_equal @group.route.name, @group.human_name
  end

  test '#group_namespace?' do
    assert @group.group_namespace?
  end

  test '#project_namespace?' do
    assert_not @group.project_namespace?
  end

  test '#user_namespace?' do
    assert_not @group.user_namespace?
  end

  test '#owner_required?' do
    assert_not @group.owner_required?
  end

  test '#validate_type' do
    assert_nil @group.validate_type
  end

  test '#validate_parent_type' do
    assert_nil @group.validate_parent_type
  end

  test '#full_name' do
    assert_equal @group.route.name, @group.full_name
  end

  test '#full_path' do
    assert_equal @group.route.path, @group.full_path
  end

  test '#abbreviated_path' do
    assert_equal 'g/subgroup-1', @subgroup_one.abbreviated_path
  end

  test '#destroy removes descendant groups, project namespaces, projects, and members' do
    self_and_descendants_count = @group_three.self_and_descendants.count
    project_namespaces = Namespaces::ProjectNamespace.where(parent: @group_three.self_and_descendants)
    projects_count = project_namespaces.count
    members_count = Member.where(namespace: @group_three.self_and_descendants).count +
                    Member.where(namespace: project_namespaces).count
    assert_difference(
      -> { Group.count } => (self_and_descendants_count * -1),
      -> { Namespaces::ProjectNamespace.count } => (projects_count * -1),
      -> { Project.count } => (projects_count * -1),
      -> { Member.count } => (members_count * -1)
    ) do
      @group_three.destroy
    end
  end

  test '#destroy removes descendant groups, project namespaces, projects, and members, then they are restored' do
    self_and_descendants_count = @group_three.self_and_descendants.count
    project_namespaces = Namespaces::ProjectNamespace.where(parent: @group_three.self_and_descendants)
    projects_count = project_namespaces.count
    members_count = Member.where(namespace: @group_three.self_and_descendants).count +
                    Member.where(namespace: project_namespaces).count
    assert_difference(
      -> { Group.count } => (self_and_descendants_count * -1),
      -> { Namespaces::ProjectNamespace.count } => (projects_count * -1),
      -> { Project.count } => (projects_count * -1),
      -> { Member.count } => (members_count * -1)
    ) do
      @group_three.destroy
    end

    assert_difference(
      -> { Group.count } => (self_and_descendants_count * +1),
      -> { Namespaces::ProjectNamespace.count } => (projects_count * +1),
      -> { Project.count } => (projects_count * +1),
      -> { Member.count } => (members_count * +1)
    ) do
      Group.restore(@group_three.id, recursive: true)
    end
  end

  test 'get ancestor namespace_group_links for subgroup' do
    subgroup2 = groups(:subgroup2)

    group_group_link1 = namespace_group_links(:namespace_group_link5)

    group_group_link2 = namespace_group_links(:namespace_group_link6)

    group_group_link3 = namespace_group_links(:namespace_group_link7)

    group_group_links = subgroup2.shared_with_group_links.of_ancestors

    assert_equal 4, group_group_links.count

    assert group_group_links.include?(group_group_link1)
    assert group_group_links.include?(group_group_link2)
    assert group_group_links.include?(namespace_group_links(:namespace_group_link2))
    assert group_group_links.include?(namespace_group_links(:namespace_group_link14))
    assert_not group_group_links.include?(group_group_link3)
  end

  test 'get self and ancestor namespace_group_links for subgroup' do
    subgroup2 = groups(:subgroup2)

    group_group_link1 = namespace_group_links(:namespace_group_link5)

    group_group_link2 = namespace_group_links(:namespace_group_link6)

    group_group_link3 = namespace_group_links(:namespace_group_link7)

    group_group_links = subgroup2.shared_with_group_links.of_ancestors_and_self

    assert_equal 5, group_group_links.count

    assert group_group_links.include?(group_group_link1)
    assert group_group_links.include?(group_group_link2)
    assert group_group_links.include?(group_group_link3)
    assert group_group_links.include?(namespace_group_links(:namespace_group_link2))
    assert group_group_links.include?(namespace_group_links(:namespace_group_link14))
  end

  test 'group should have metadata summary with metadata fields and their counts from projects within' do
    expected_metadata_summary = @group.metadata_summary
    actual_metadata_summary = {}

    group_project_namespaces = @group.project_namespaces
    group_project_namespaces.each do |gpn|
      actual_metadata_summary.merge!(gpn.metadata_summary) { |_key, old_value, new_value| old_value + new_value }
    end

    assert_equal expected_metadata_summary, actual_metadata_summary
  end
end
