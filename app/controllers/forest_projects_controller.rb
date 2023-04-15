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
      ProcessForestProject.perform_later(@forest_project.id, session[:user_id])
      redirect_to forest_project_path(@forest_project), notice: 'Project created successfully.'
    else
      render :new
    end
  end

  def reprocess
    @forest_project = current_user.forest_projects.find(params[:id])

    if @forest_project.present?
      ProcessForestProject.perform_later(@forest_project.id, session[:user_id])
      redirect_to forest_project_path(@forest_project), notice: 'File reprocessing started.'
    else
      redirect_to forest_projects_path, alert: 'Project not found.'
    end
  end

  def show
    @forest_project = current_user.forest_projects.find(params[:id])

    @species_summary = @forest_project.species_summary || nil
    @condition_summary = @forest_project.condition_summary || nil
    @dbh_summary = @forest_project.dbh_summary || nil
    if @forest_project.csv
      csv_contents = @forest_project.csv.download
      @csv_data = CSV.parse(csv_contents, headers: true, header_converters: :symbol).map(&:to_h)
      @csv_filename = @forest_project.csv.filename.to_s
      @csv_url = url_for(@forest_project.csv) if @forest_project.csv.attached?
    end
    @google_sheet = @forest_project.google_sheet || nil
    @google_doc = @forest_project.google_doc || nil
  end

  def download_csv
    @forest_project = current_user.forest_projects.find(params[:id])
    send_data @forest_project.csv.download, filename: @forest_project.csv.filename.to_s
  end

  private

  def project_params
    params.require(:forest_project).permit(:client_name, :project_name, :csv)
  end
end
