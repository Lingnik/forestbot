class AddTreeCountsToForestProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :forest_projects, :tree_counts, :json

    remove_column :forest_projects, :good, :integer
    remove_column :forest_projects, :fair, :integer
    remove_column :forest_projects, :poor, :integer
    remove_column :forest_projects, :excellent, :integer
    remove_column :forest_projects, :dead, :integer
    remove_column :forest_projects, :min_dbh, :float
    remove_column :forest_projects, :max_dbh, :float
  end
end
