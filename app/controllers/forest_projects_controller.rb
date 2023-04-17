require 'csv'

class ForestProjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    entry_dbg
    @forest_projects = current_user.forest_projects.order(created_at: :desc)
    current_user.refresh_tokens!
  end

  def new
    entry_dbg
    @forest_project = ForestProject.new
  end

  def status
    @forest_project = current_user.forest_projects.find(params[:id])
    render json: { status: @forest_project.status }
  end

  def create
    entry_dbg
    @forest_project = current_user.forest_projects.build(project_params)

    if @forest_project.save
      ProcessForestProject.perform_later(@forest_project.id, session[:user_id])
      redirect_to forest_project_path(@forest_project), notice: 'Project created successfully.'
    else
      render :new
    end
  end

  def reprocess
    entry_dbg
    @forest_project = current_user.forest_projects.find(params[:id])

    if @forest_project.present?
      ProcessForestProject.perform_later(@forest_project.id, session[:user_id])
      redirect_to forest_project_path(@forest_project), notice: 'File reprocessing started.'
    else
      redirect_to forest_projects_path, alert: 'Project not found.'
    end
  end

  def show
    entry_dbg
    user_id = session[:user_id]
    @forest_project = current_user.forest_projects.find(params[:id])

    @species_summary = @forest_project.species_summary || nil
    @condition_summary = @forest_project.condition_summary || nil
    @dbh_summary = @forest_project.dbh_summary || nil
    @total_sites = @forest_project.total_sites || nil

    @fraxinus_species_summary = @forest_project.fraxinus_species_summary || nil
    @fraxinus_condition_summary = @forest_project.fraxinus_condition_summary || nil
    @fraxinus_dbh_summary = @forest_project.fraxinus_dbh_summary || nil
    @fraxinus_total_sites = @forest_project.fraxinus_total_sites || nil

    if @forest_project.csv
      csv_contents = @forest_project.csv.download
      @csv_data = CSV.parse(csv_contents, headers: true, header_converters: :symbol).map(&:to_h)
      @csv_filename = @forest_project.csv.filename.to_s
      @csv_url = url_for(@forest_project.csv) if @forest_project.csv.attached?
    end

    @google_folder = @forest_project.google_folder || nil
    @google_sheet = @forest_project.google_sheet || nil
    @google_doc = @forest_project.google_doc || nil
  end

  def download_csv
    entry_dbg
    @forest_project = current_user.forest_projects.find(params[:id])
    send_data @forest_project.csv.download, filename: @forest_project.csv.filename.to_s
  end

  private

  def project_params
    entry_dbg
    params.require(:forest_project).permit(:client_name, :project_name, :csv, :project_date)
  end
end
