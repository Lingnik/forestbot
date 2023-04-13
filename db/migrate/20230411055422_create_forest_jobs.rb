class CreateForestJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :forest_jobs do |t|
      t.references :forest_project, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
