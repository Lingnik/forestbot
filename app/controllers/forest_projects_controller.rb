require 'csv'

class ForestProjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    @forest_projects = current_user.forest_projects.order(created_at: :desc)
  end

  def new
    @forest_project = ForestProject.new
  end

  def create
    @forest_project = current_user.forest_projects.build(project_params)

    if @forest_project.save
      ProcessForestProject.perform_later(@forest_project.id)
      redirect_to forest_project_path(@forest_project), notice: 'Project created successfully.'
    else
      render :new
    end
  end

  def show
    @forest_project = current_user.forest_projects.find(params[:id])
    csv_contents = @forest_project.csv.download
    @csv_data = CSV.parse(csv_contents, headers: true, header_converters: :symbol).map(&:to_h)
  end

  private

  def project_params
    params.require(:forest_project).permit(:client_name, :project_name, :csv)
  end
end
