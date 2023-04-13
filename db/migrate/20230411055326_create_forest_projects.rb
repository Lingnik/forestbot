class CreateForestProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :forest_projects do |t|
      t.references :user, null: false, foreign_key: true
      t.string :client_name
      t.string :project_name
      t.string :status
      t.integer :good
      t.integer :fair
      t.integer :poor
      t.integer :excellent
      t.integer :dead
      t.float :min_dbh
      t.float :max_dbh
      t.string :csv_url
      t.string :google_drive_folder_id
      t.string :google_spreadsheet_id
      t.string :google_doc_id

      t.timestamps
    end
  end
end
