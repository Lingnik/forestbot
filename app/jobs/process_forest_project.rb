require 'csv'
require 'google_drive_client'

class ProcessForestProject < ApplicationJob
  queue_as :default

  def perform(project_id, user_id)
    begin
      project = ForestProject.find(project_id)

      project.update(status: 'Calculating')

      csv_data = read_and_validate_csv(project.csv)
      tree_counts = count_trees(csv_data)

      project.update(status: 'Creating Docs', tree_counts: tree_counts)

      conn = GoogleApiConnectionManager.new(user_id)
      google = GoogleDriveClient.new(conn.credentials)

      folder = google.create_folder(
        "#{project.client_name} - #{project.project_name}",
        parent_id: ENV['GOOGLE_DRIVE_FOLDER_ID']
      )
      sheet = google.create_spreadsheet_from_template(
        "#{project.client_name} - #{project.project_name} Spreadsheet",
        folder,
        ENV['GOOGLE_SHEETS_TEMPLATE_ID']
      )
      doc = google.create_document_from_template(
        "#{project.client_name} - #{project.project_name} Document",
        folder,
        ENV['GOOGLE_DOCS_TEMPLATE_ID']
      )

      project.update(status: 'Done')
    rescue StandardError => e
      # Update project with the error message and set status to 'Error'
      now = Time.current
      project.update(status: 'Error', error_message: "#{now}\n\n#{e.message}\n\n#{e.backtrace.join("\n")}")
    end
  end

  private

  def read_and_validate_csv(csv)
    begin
      # Define the expected header row
      expected_headers = %w[pid common_name scientific_name condition tree_workpruning tree_workother tree_tag dbh within_years cycle tree_height_estimated crown_spread notesmgmt observation_comments observationscharacteristics special_equipment]

      csv_contents = csv.download
      csv_data = CSV.parse(csv_contents, headers: true, header_converters: :symbol).map(&:to_h)

      # Validate the header row
      actual_headers = csv_data.first.keys.map(&:to_s)
      unless actual_headers == expected_headers
        raise "Invalid header row. Expected: #{expected_headers}, Actual: #{actual_headers}"
      end

      csv_data
    rescue => e
      project.update(status: 'Error Parsing CSV', error_message: e.message)
      raise e
    end
  end

  def summarize_species(csv_data)
    species_counts = Hash.new
    csv_data.each do |row|
      key = row[:common_name].downcase.strip
      unless species_counts[key]
        species_counts[key] = {
          count: 0,
          common: row[:common_name],
          latin: row[:scientific_name]
        }
      end
      species_counts[key][:count] += 1
    end
    species_counts.sort_by { |common_name, _| common_name }.to_h
  end

  def summarize_dbh(csv_data)
    min_dbh = Float::INFINITY
    max_dbh = -Float::INFINITY
    csv_data.each do |row|
      # Update min and max DBH values
      dbh = row[:dbh].to_f
      min_dbh = [min_dbh, dbh].min
      max_dbh = [max_dbh, dbh].max
    end

    { min_dbh: min_dbh, max_dbh: max_dbh }
  end

  def summarize_conditions(csv_data)
    # Initialize tree condition counters
    condition_counts = Hash.new(0)

    # Iterate through the CSV data
    csv_data.each do |row|
      # Update tree condition counters
      condition_name = row[:condition].downcase.strip
      condition_counts[condition_name] += 1
    end

    condition_counts
  end

  def count_trees(csv_data)
    # begin
    condition_summary = summarize_conditions(csv_data)
    species_summary = summarize_species(csv_data)
    dbh_summary = summarize_dbh(csv_data)

    { condition_summary: condition_summary, species_summary: species_summary, dbh_summary: dbh_summary }
    # rescue => e
    #   project.update(status: 'Error Counting Trees', error_message: e.message)
    #   raise e
    # end
  end

end

