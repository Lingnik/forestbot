class CreateForestProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :forest_projects do |t|
      t.references :user, null: false, foreign_key: true

      t.string :client_name
      t.string :client_address
      t.string :project_name
      t.date :project_date

      t.string :project_type
      t.string :status
      t.text :error_message

      t.string :csv_url
      t.json :tree_counts
      t.string :google_drive_folder_id
      t.string :google_spreadsheet_id
      t.string :google_doc_id

      t.timestamps
    end

    add_index :forest_projects, :status, unique: false
    add_index :forest_projects, :project_type, unique: false
  end
end
