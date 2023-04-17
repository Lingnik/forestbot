class AddProjectDateToForestProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :forest_projects, :project_date, :date
  end
end
