# frozen_string_literal: true

require 'test_helper'

class GroupsMembershipActionsConcernTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'group members index' do
    sign_in users(:john_doe)

    group = groups(:group_one)
    get group_members_path(group)

    assert_response :success
    assert_equal 3, group.group_members.count
  end

  test 'group members index invalid route get' do
    sign_in users(:john_doe)

    assert_raises(ActionController::RoutingError) do
      get group_members_path(group_id: 'test-group-not-exists')
    end
  end

  test 'group members new' do
    sign_in users(:john_doe)

    group = groups(:group_one)
    get new_group_member_path(group)

    assert_response :success
    assert_equal 3, group.group_members.count
  end

  test 'group members new invalid route get' do
    sign_in users(:john_doe)

    assert_raises(ActionController::RoutingError) do
      get new_group_member_path(group_id: 'test-group-not-exists')
    end
  end

  test 'group members create' do
    sign_in users(:john_doe)

    group = groups(:group_one)
    get group_members_path(group)
    user = users(:john_doe)

    post group_members_path, params: { member: { user_id: users(:steve_doe).id,
                                                 namespace_id: group.id,
                                                 created_by_id: user.id,
                                                 type: 'GroupMember',
                                                 access_level: Member::AccessLevel::OWNER } }

    assert_redirected_to group_members_path(group)
    assert_equal 4, group.group_members.count
  end

  test 'group members create invalid post data' do
    sign_in users(:john_doe)
    user = users(:john_doe)
    group = groups(:group_one)

    post group_members_path(group), params: { member: { user_id: user.id,
                                                        namespace_id: group.id,
                                                        created_by_id: user.id,
                                                        type: 'GroupMember',
                                                        access_level: Member::AccessLevel::OWNER + 100_000 } }
    assert_response :unprocessable_entity
  end

  test 'group members destroy' do
    sign_in users(:john_doe)

    group = groups(:group_one)
    get group_members_path(group)
    group_member = members_group_members(:group_one_member_james_doe)

    delete group_member_path(group, group_member)

    assert_redirected_to group_members_path(group)
    assert_equal 2, group.group_members.count
  end

  test 'group members destroy invalid route delete' do
    sign_in users(:john_doe)

    assert_raises(ActionController::RoutingError) do
      group_member = members_group_members(:group_one_member_james_doe)
      delete group_member_path('test-group-not-exists', group_member)
    end
  end

  test 'group members create invalid' do
    sign_in users(:john_doe)

    group = groups(:group_one)
    get group_members_path(group)
    user = users(:john_doe)

    post group_members_path, params: { member: { user_id: user.id,
                                                 namespace_id: group.id,
                                                 created_by_id: user.id,
                                                 type: 'GroupMember',
                                                 access_level: Member::AccessLevel::OWNER + 100_000 } }

    assert_response 422 # unprocessable entity
  end

  test 'group members destroy invalid' do
    sign_in users(:joan_doe)

    group = groups(:group_one)
    group_member = members_group_members(:group_one_member_james_doe)

    assert_no_changes -> { group.group_members.count } do
      delete group_member_path(group, group_member)
    end

    assert_response 302 # Redirect back to group members page
    assert_redirected_to group_members_path(group)
  end
end
