class AddSlugToJobApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :job_applications, :slug, :string
    add_index  :job_applications, :slug, unique: true
  end
end
