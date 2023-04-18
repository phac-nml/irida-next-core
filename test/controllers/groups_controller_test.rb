# frozen_string_literal: true

require 'test_helper'

class GroupsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'should get index' do
    sign_in users(:john_doe)

    get groups_path
    assert_response :success
  end

  test 'should show the group' do
    sign_in users(:john_doe)

    group = groups(:group_one)
    get group_path(group)
    assert_response :success
  end

  test 'should display create new group page' do
    sign_in users(:john_doe)

    get new_group_path
    assert_response :success
  end

  test 'should create a new group' do
    sign_in users(:john_doe)

    assert_difference('Group.count') do
      post groups_path, params: { group: { name: 'New Group', path: 'new_group', description: 'This is a new group' } }
    end

    assert_redirected_to group_path(Group.last.full_path)
  end

  test 'should not create a new group with invalid params' do
    sign_in users(:john_doe)

    assert_no_difference('Group.count') do
      post groups_path, params: { group: { name: 'Ne', path: 'new_group', description: 'This is a new group' } }
    end

    assert_response :unprocessable_entity
  end

  test 'should update a group' do
    sign_in users(:john_doe)

    group = groups(:group_one)
    patch group_path(group), params: { group: { name: 'New Group Name' } }
    assert_redirected_to group_path(group)
  end

  test 'should not update a group with invalid params' do
    sign_in users(:john_doe)

    group = groups(:group_one)
    assert_no_changes -> { group.name } do
      patch group_path(group), params: { group: { name: 'NG' } }
    end
    assert_response :unprocessable_entity
  end

  test 'should show the sub group' do
    sign_in users(:john_doe)

    subgroup = groups(:subgroup1)
    get group_path(subgroup)
    assert_response :success
  end

  test 'should delete a group' do
    sign_in users(:john_doe)

    group = groups(:group_one)
    assert_difference('Group.count', -1) do
      delete group_path(group)
    end

    assert_redirected_to groups_path
  end

  test 'should not show a sub group that doesn\'t exist' do
    sign_in users(:john_doe)

    group = groups(:group_one)
    assert_raises(ActionController::RoutingError) do
      get group_path("#{group.full_path}/fakesubgroup")
    end
  end

  test 'should not delete a group' do
    sign_in users(:joan_doe)

    group = groups(:group_one)
    assert_no_difference('Group.count') do
      delete group_path(group)
    end

    assert_response :unauthorized
  end
end
