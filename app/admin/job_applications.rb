ActiveAdmin.register JobApplication do
  permit_params :user_id, :company, :job_title, :job_url, :location, :source, :stage, :notes

  index do
    selectable_column
    id_column
    column :company
    column :job_title
    column :job_url
    column :location
    column :source
    column :stage
    column :notes
  end
end