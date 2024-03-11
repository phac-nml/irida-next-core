# frozen_string_literal: true

# migration to add files updated at column to samples table
class AddFilesUpdatedAtToSamples < ActiveRecord::Migration[7.1]
  def up
    add_column :samples, :files_updated_at, :datetime

    execute <<-SQL.squish
      with t AS (
        SELECT attachments.attachable_id, MAX(attachments.created_at) AS max_created_datetime
        FROM attachments
        GROUP BY attachments.attachable_id
      )

      UPDATE samples SET files_updated_at = t.max_created_datetime
      FROM t
      WHERE samples.id = t.attachable_id;
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
