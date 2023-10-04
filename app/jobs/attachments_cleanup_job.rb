# frozen_string_literal: true

# delete/destroy attachements that have been deleted X days ago
class AttachmentsCleanupJob < ApplicationJob
  queue_as :default

  # Finds all deleted attachments more than `days_old`` days old, and destroys them
  # Params:
  # +days_old+:: Number of days old and older to destroy. Default is 7
  def perform(days_old = 7)
    # Do something later
    Rails.logger.info "Cleaning up all deleted attachments which are at least #{days_old} days old."

    # SELECT "attachments".* FROM "attachments"
    #   WHERE "attachments"."deleted_at" IS NOT NULL AND "attachements"."deleted_at" <= $1
    attachments_to_delete = Attachment.only_deleted.where(deleted_at: ..(Time.yesterday.midnight - days_old.day))
    attachments_to_delete.each(&:really_destroy!)
  end
end
