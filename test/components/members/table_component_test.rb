# frozen_string_literal: true

require 'test_helper'

module Members
  class TableComponentTest < ViewComponent::TestCase
    test 'Should render a table of group members' do
      namespace = groups(:group_one)
      user = users(:john_doe)
      members = Member.for_namespace_and_ancestors(namespace).not_expired

      with_request_url '/-/groups/group-1/-/members' do
        q = Member.ransack({ s: 'user_email asc', user_email_cont: 'admin' })

        render_inline TableComponent.new(
          namespace,
          members,
          Member::AccessLevel.access_level_options_owner,
          q,
          user,
          {
            update_member: true,
            destroy_member: true
          }
        )

        assert_selector 'table', count: 1
      end
    end

    test 'Should render a table of project members' do
      project =  projects(:project1)
      namespace = project.namespace
      user = users(:john_doe)
      members = Member.for_namespace_and_ancestors(namespace).not_expired

      with_request_url '/-/projects/project-1/-/members' do
        q = Member.ransack({ s: 'user_email asc', user_email_cont: 'admin' })

        render_inline TableComponent.new(
          namespace,
          members,
          Member::AccessLevel.access_level_options_owner,
          q,
          user,
          {
            update_member: true,
            destroy_member: true
          }
        )

        assert_selector 'table', count: 1
      end
    end
  end
end
