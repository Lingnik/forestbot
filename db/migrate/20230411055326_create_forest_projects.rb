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
      t.text :error_message, false

      t.string :csv_url
      t.json :tree_counts, false
      t.string :google_drive_folder_id
      t.string :google_spreadsheet_id
      t.string :google_doc_id

      t.timestamps
    end
  end
end
