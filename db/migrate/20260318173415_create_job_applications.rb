class CreateJobApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :job_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :company
      t.string :job_title
      t.string :job_url
      t.string :location
      t.string :source
      t.string :stage
      t.text :notes

      t.timestamps
    end
  end
end
