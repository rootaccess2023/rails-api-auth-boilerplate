class CreateJobApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :job_applications do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.string  :role_title, null: false
      t.integer :status,     null: false, default: 0
      t.string  :location
      t.string  :source
      t.date    :applied_on

      t.timestamps
    end
  end
end
