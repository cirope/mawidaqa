class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :job, null: false
      t.integer :lock_version, null: false, default: 0
      t.references :user, null: false
      t.references :organization, null: false

      t.timestamps
    end

    add_index :jobs, :user_id
    add_index :jobs, :organization_id
  end
end
