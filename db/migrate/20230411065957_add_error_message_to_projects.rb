class AddErrorMessageToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :forest_projects, :error_message, :text
  end
end
