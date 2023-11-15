# frozen_string_literal: true

require 'application_system_test_case'

module Projects
  class SamplesTest < ApplicationSystemTestCase
    setup do
      @user = users(:john_doe)
      login_as @user
      @sample1 = samples(:sample1)
      @sample2 = samples(:sample2)
      @project = projects(:project1)
      @namespace = groups(:group_one)
    end

    test 'visiting the index' do
      visit namespace_project_samples_url(namespace_id: @namespace.path, project_id: @project.path)
      assert_selector 'h1', text: I18n.t('projects.samples.index.title')
      assert_selector 'table#samples-table tr', count: 2
      assert_text @sample1.name
      assert_text @sample2.name

      assert_selector 'button.Viral-Dropdown--icon', count: 5
    end

    test 'cannot access project samples' do
      login_as users(:user_no_access)

      visit namespace_project_samples_url(namespace_id: @namespace.path, project_id: @project.path)

      assert_text I18n.t(:'action_policy.policy.project.sample_listing?', name: @project.name)
    end

    test 'should create sample' do
      visit namespace_project_samples_url(namespace_id: @namespace.path, project_id: @project.path)
      assert_selector 'a', text: I18n.t('projects.samples.index.new_button'), count: 1
      click_on I18n.t('projects.samples.index.new_button')

      fill_in I18n.t('activerecord.attributes.sample.description'), with: @sample1.description
      fill_in I18n.t('activerecord.attributes.sample.name'), with: 'New Name'
      click_on I18n.t('projects.samples.new.submit_button')

      assert_text I18n.t('projects.samples.create.success')
      assert_text 'New Name'
      assert_text @sample1.description
    end

    test 'should update Sample' do
      visit namespace_project_sample_url(namespace_id: @namespace.path, project_id: @project.path, id: @sample1.id)
      assert_selector 'a', text: I18n.t('projects.samples.show.edit_button'), count: 1
      click_on I18n.t('projects.samples.show.edit_button'), match: :first

      fill_in 'Description', with: @sample1.description
      fill_in 'Name', with: 'New Sample Name'
      click_on I18n.t('projects.samples.edit.submit_button')

      assert_text I18n.t('projects.samples.update.success')
      assert_text 'New Sample Name'
      assert_text @sample1.description
    end

    test 'user with role >= Maintainer should be able to attach a file to a Sample' do
      visit namespace_project_sample_url(namespace_id: @namespace.path, project_id: @project.path, id: @sample2.id)
      assert_selector 'a', text: I18n.t('projects.samples.show.new_attachment_button'), count: 1
      within('#attachments') do
        assert_text I18n.t('projects.samples.show.no_files')
        assert_text I18n.t('projects.samples.show.no_associated_files')
        assert_no_text 'test_file.fastq'
      end
      click_on I18n.t('projects.samples.show.upload_files')

      within('dialog') do
        attach_file 'attachment[files][]', Rails.root.join('test/fixtures/files/test_file.fastq')
        click_on I18n.t('projects.samples.show.upload')
      end

      assert_text I18n.t('projects.samples.attachments.create.success', filename: 'test_file.fastq')
      within('#attachments') do
        assert_no_text I18n.t('projects.samples.show.no_files')
        assert_no_text I18n.t('projects.samples.show.no_associated_files')
        assert_text 'test_file.fastq'
      end
    end

    test 'user with role >= Maintainer should not be able to attach a duplicate file to a Sample' do
      visit namespace_project_sample_url(namespace_id: @namespace.path, project_id: @project.path, id: @sample1.id)
      assert_selector 'a', text: I18n.t('projects.samples.show.new_attachment_button'), count: 1
      click_on I18n.t('projects.samples.show.upload_files')

      within('dialog') do
        attach_file 'attachment[files][]', Rails.root.join('test/fixtures/files/test_file.fastq')
        click_on I18n.t('projects.samples.show.upload')
      end

      assert_text 'checksum matches existing file'
    end

    test 'user with role >= Maintainer should be able to delete a file from a Sample' do
      visit namespace_project_sample_url(namespace_id: @namespace.path, project_id: @project.path, id: @sample1.id)
      assert_selector 'button', text: I18n.t('projects.samples.attachments.attachment.delete'), count: 2
      click_on I18n.t('projects.samples.attachments.attachment.delete'), match: :first

      within('#turbo-confirm[open]') do
        click_button I18n.t(:'components.confirmation.confirm')
      end

      assert_text I18n.t('projects.samples.attachments.destroy.success', filename: 'test_file.fastq')
      within('#attachments') do
        assert_no_text 'test_file.fastq'
      end
    end

    test 'should destroy Sample' do
      visit namespace_project_sample_url(namespace_id: @namespace.path, project_id: @project.path, id: @sample1.id)
      assert_selector 'a', text: I18n.t('projects.samples.index.remove_button'), count: 1
      click_link I18n.t(:'projects.samples.index.remove_button')

      within('#turbo-confirm[open]') do
        click_button I18n.t(:'components.confirmation.confirm')
      end

      assert_text I18n.t('projects.samples.destroy.success', sample_name: @sample1.name)
    end

    test 'should transfer samples' do
      project2 = projects(:project2)
      visit namespace_project_samples_url(namespace_id: @namespace.path, project_id: @project.path)
      assert_selector 'table#samples-table tr', count: 2
      all('input[type=checkbox]').each { |checkbox| checkbox.click unless checkbox.checked? }
      click_link I18n.t('projects.samples.index.transfer_button'), match: :first
      within('span[data-controller-connected="true"] dialog') do
        select project2.full_path, from: I18n.t('projects.samples.transfers._transfer_modal.new_project_id')
        click_on I18n.t('projects.samples.transfers._transfer_modal.submit_button')
      end
      within %(turbo-frame[id="project_samples_list"]) do
        assert_selector 'table#samples-table tr', count: 0
      end
    end

    test 'should not transfer samples' do
      project26 = projects(:project26)
      visit namespace_project_samples_url(namespace_id: @namespace.path, project_id: @project.path)
      assert_selector 'table#samples-table tr', count: 2
      all('input[type=checkbox]').each { |checkbox| checkbox.click unless checkbox.checked? }
      click_link I18n.t('projects.samples.index.transfer_button'), match: :first
      within('span[data-controller-connected="true"] dialog') do
        select project26.full_path, from: I18n.t('projects.samples.transfers._transfer_modal.new_project_id')
        click_on I18n.t('projects.samples.transfers._transfer_modal.submit_button')
      end
      within %(turbo-frame[id="transfer_alert"]) do
        assert_text I18n.t('projects.samples.transfers.create.error')
        errors = @project.errors.full_messages_for(:samples)
        errors.each { |error| assert_text error }
      end
      within %(turbo-frame[id="project_samples_list"]) do
        assert_selector 'table#samples-table tr', count: 2
      end
    end

    test 'should transfer some samples' do
      project25 = projects(:project25)
      visit namespace_project_samples_url(namespace_id: @namespace.path, project_id: @project.path)
      assert_selector 'table#samples-table tr', count: 2
      all('input[type=checkbox]').each { |checkbox| checkbox.click unless checkbox.checked? }
      click_link I18n.t('projects.samples.index.transfer_button'), match: :first
      within('span[data-controller-connected="true"] dialog') do
        select project25.full_path, from: I18n.t('projects.samples.transfers._transfer_modal.new_project_id')
        click_on I18n.t('projects.samples.transfers._transfer_modal.submit_button')
      end
      within %(turbo-frame[id="transfer_alert"]) do
        assert_text I18n.t('projects.samples.transfers.create.error')
        errors = @project.errors.full_messages_for(:samples)
        errors.each { |error| assert_text error }
      end
      within %(turbo-frame[id="project_samples_list"]) do
        assert_selector 'table#samples-table tr', count: 1
      end
    end

    test 'user with maintainer access should not be able to see the transfer samples button' do
      user = users(:joan_doe)
      login_as user

      visit namespace_project_samples_url(namespace_id: @namespace.path, project_id: @project.path)

      assert_selector 'a', text: I18n.t('projects.samples.index.transfer_button'), count: 0
    end

    test 'user with guest access should not be able to see the transfer samples button' do
      user = users(:ryan_doe)
      login_as user

      visit namespace_project_samples_url(namespace_id: @namespace.path, project_id: @project.path)

      assert_selector 'a', text: I18n.t('projects.samples.index.transfer_button'), count: 0
    end

    test 'user should not be able to see the edit button for the sample' do
      user = users(:ryan_doe)
      login_as user

      visit namespace_project_sample_url(namespace_id: @namespace.path, project_id: @project.path, id: @sample1.id)

      assert_selector 'a', text: I18n.t('projects.samples.show.edit_button'), count: 0
    end

    test 'user should not be able to see the remove button for the sample' do
      user = users(:ryan_doe)
      login_as user

      visit namespace_project_sample_url(namespace_id: @namespace.path, project_id: @project.path, id: @sample1.id)

      assert_selector 'a', text: I18n.t('projects.samples.index.remove_button'), count: 0
    end

    test 'user should not be able to see the upload file button for the sample' do
      user = users(:ryan_doe)
      login_as user

      visit namespace_project_sample_url(namespace_id: @namespace.path, project_id: @project.path, id: @sample1.id)

      assert_selector 'a', text: I18n.t('projects.samples.index.upload_file'), count: 0
    end

    test 'visiting the index should not allow the current user only edit action' do
      user = users(:joan_doe)
      login_as user

      visit namespace_project_samples_url(namespace_id: @namespace.path, project_id: @project.path)

      assert_selector 'a', text: I18n.t('projects.samples.index.new_button'), count: 1
      assert_selector 'h1', text: I18n.t('projects.samples.index.title')
      assert_selector 'table#samples-table tr', count: 2
      assert_selector 'table#samples-table tr button.Viral-Dropdown--icon', text: '', count: 2
      first('table#samples-table tr button.Viral-Dropdown--icon').click
      assert_selector 'a', text: 'Edit', count: 1
      assert_selector 'a', text: 'Remove', count: 0
      assert_text @sample1.name
      assert_text @sample2.name
    end

    test 'visiting the index should not allow the current user any modification actions' do
      user = users(:ryan_doe)
      login_as user

      visit namespace_project_samples_url(namespace_id: @namespace.path, project_id: @project.path)

      assert_selector 'a', text: I18n.t('projects.samples.index.new_button'), count: 0
      assert_selector 'h1', text: I18n.t('projects.samples.index.title')
      assert_selector 'table#samples-table tr', count: 2
      assert_selector 'table#samples-table tr button.Viral-Dropdown--icon', text: '', count: 0
      assert_text @sample1.name
      assert_text @sample2.name
    end

    test 'should concatenate attachment files and keep originals' do
      visit namespace_project_sample_url(namespace_id: @namespace.path, project_id: @project.path, id: @sample1.id)
      within %(turbo-frame[id="attachments"]) do
        assert_selector 'table #attachments-table-body tr', count: 2
        all('input[type=checkbox]').each { |checkbox| checkbox.click unless checkbox.checked? }
      end
      click_link I18n.t('projects.samples.show.concatenate_button'), match: :first
      within('span[data-controller-connected="true"] dialog') do
        fill_in I18n.t('projects.samples.attachments.concatenations.modal.basename'), with: 'concatenated_file'
        click_on I18n.t('projects.samples.attachments.concatenations.modal.submit_button')
      end
      within %(turbo-frame[id="attachments"]) do
        assert_text 'concatenated_file'
        assert_selector 'table #attachments-table-body tr', count: 3
      end
    end

    test 'should concatenate attachment files and remove originals' do
      visit namespace_project_sample_url(namespace_id: @namespace.path, project_id: @project.path, id: @sample1.id)
      within %(turbo-frame[id="attachments"]) do
        assert_selector 'table #attachments-table-body tr', count: 2
        all('input[type=checkbox]').each { |checkbox| checkbox.click unless checkbox.checked? }
      end
      click_link I18n.t('projects.samples.show.concatenate_button'), match: :first
      within('span[data-controller-connected="true"] dialog') do
        fill_in I18n.t('projects.samples.attachments.concatenations.modal.basename'), with: 'concatenated_file'
        check 'Delete originals'
        click_on I18n.t('projects.samples.attachments.concatenations.modal.submit_button')
      end
      within %(turbo-frame[id="attachments"]) do
        assert_text 'concatenated_file'
        assert_selector 'table #attachments-table-body tr', count: 1
      end
    end

    test 'user with guest access should not be able to see the concatenate attachment files button' do
      user = users(:ryan_doe)
      login_as user

      visit namespace_project_sample_url(namespace_id: @namespace.path, project_id: @project.path, id: @sample1.id)

      assert_selector 'a', text: I18n.t('projects.samples.show.concatenate_button'), count: 0
    end
  end
end
