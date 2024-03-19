# frozen_string_literal: true

require 'test_helper'

class DataExportMailerTest < ActionMailer::TestCase
  setup do
    @data_export2 = data_exports(:data_export_two)
    @data_export3 = data_exports(:data_export_three)
    @data_export4 = data_exports(:data_export_four)
    @data_export5 = data_exports(:data_export_five)
  end
  test 'export ready email with export name' do
    freeze_time
    email = DataExportMailer.export_ready(@data_export4)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@data_export4.user.email], email.to
    assert_equal I18n.t('mailers.data_export_mailer.email_subject'), email.subject
    assert_match "#{I18n.t('mailers.data_export_mailer.export_ready.greeting')} #{@data_export4.user.first_name}",
                 email.body.to_s
    assert_no_match @data_export4.id, email.body.to_s
    assert_match @data_export4.expires_at.strftime('%A, %B %d, %Y'), email.body.to_s
  end

  test 'export ready email without export name' do
    freeze_time
    email = DataExportMailer.export_ready(@data_export5)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@data_export5.user.email], email.to
    assert_equal I18n.t('mailers.data_export_mailer.email_subject'), email.subject
    assert_match "#{I18n.t('mailers.data_export_mailer.export_ready.greeting')} #{@data_export5.user.first_name}",
                 email.body.to_s
    assert_match @data_export5.id, email.body.to_s
    assert_match @data_export5.expires_at.strftime('%A, %B %d, %Y'), email.body.to_s
  end

  test 'email delivery when email_notification is true' do
    assert_emails 1 do
      DataExports::CreateJob.perform_now(@data_export2)
    end
  end

  test 'no email delivery when email_notification is nil' do
    assert_emails 0 do
      DataExports::CreateJob.perform_now(@data_export3)
    end
  end
end
