class CreateFollowUps < ActiveRecord::Migration[7.1]
  def change
    create_table :follow_ups do |t|
      t.references :user,            null: false, foreign_key: true
      t.references :job_application, null: true,  foreign_key: true
      t.string     :title,           null: false
      t.datetime   :due_at,          null: false
      t.datetime   :completed_at

      t.timestamps
    end

    add_index :follow_ups, %i[user_id completed_at]
  end
end
