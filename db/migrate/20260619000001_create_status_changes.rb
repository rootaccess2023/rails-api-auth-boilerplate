class CreateStatusChanges < ActiveRecord::Migration[7.1]
  def change
    create_table :status_changes do |t|
      t.references :job_application, null: false, foreign_key: true
      t.integer :from_status
      t.integer :to_status, null: false
      t.datetime :changed_at, null: false
      t.timestamps
    end
  end
end
