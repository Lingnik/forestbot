# app/jobs/process_forest_project.rb

require 'csv'
require 'google_drive_client'

class ProcessForestProject < ApplicationJob
  queue_as :default

  def perform(project_id, user_id)
    entry_dbg
    begin
      project = ForestProject.find(project_id)
      @project = project
      project.update(error_message: nil) if project.error_message
      user = User.find(user_id)

      project.update(status: 'Calculating')

      csv_data = read_and_validate_csv(project.csv)
      tree_counts = count_trees(csv_data)
      tree_counts.merge!(count_trees(csv_data, only_fraxinus: true))
      total_ash_trees = tree_counts[:fraxinus_total_sites]

      project.update(status: 'Creating Folder', tree_counts: tree_counts)

      google = GoogleDriveClient.new(user)

      folder = google.create_folder(
        "#{project.client_name} - #{project.project_name} - #{project.project_date}",
        ENV['GOOGLE_DRIVE_FOLDER_ID']
      )

      _ = project.update!(status: "Creating Sheet", google_drive_folder_id: folder.id)
      sheet = google.copy_file(
        ENV['GOOGLE_SHEETS_TEMPLATE_ID'],
        "Data- #{project.client_name} - #{project.project_name} - #{project.project_date}",
        folder.id
      )

      # Populate sheet with CSV data
      google.append_csv_to_spreadsheet(sheet.id, csv_data)

      _ = project.update!(status: "Creating Doc", google_spreadsheet_id: sheet.id)
      doc = google.copy_file(
        ENV['GOOGLE_DOCS_TEMPLATE_ID'],
        "Report- #{project.client_name} - #{project.project_name} - #{project.project_date}",
        folder.id
      )

      _ = project.update!(status: "Populating Doc", google_doc_id: doc.id)
      google.replace_placeholders_in_doc_with_values(
        doc.id,
        [
          { '{{client_name}}': project.client_name.to_s },
          { '{{project_name}}': project.project_name.to_s },
          { '{{project_date}}': project.project_date.to_s },
          { '{{total_sites}}': project.total_sites.to_s },
          { '{{total_ash_trees}}': total_ash_trees.to_s },
          { '{{data_table}}': "=IMPORTDATA(\"https://docs.google.com/spreadsheets/d/#{sheet.id}/gviz/tq?tqx=out:csv&sheet=Data\")" }
        ]
      )

      _ = project.update!(status: "Inserting Table")
      google.insert_table_into_doc(doc.id, csv_data)

      project.update(status: 'Done')
    rescue StandardError => e
      # Update project with the error message and set status to 'Error'
      now = Time.current
      project.update(status: 'Processing Error', error_message: "#{now}\n\n#{e.message}\n\n#{e.backtrace.join("\n")}")
    end
  end

  private

  def read_and_validate_csv(csv)
    entry_dbg
    begin
      # Define the expected header row
      mandatory_headers = %w[pid common_name scientific_name condition dbh]

      csv_contents = csv.download
      csv_data = CSV.parse(csv_contents, headers: true, header_converters: :symbol).map(&:to_h)

      # Validate the header row
      actual_headers = csv_data.first.keys
      actual_headers_s = actual_headers.map(&:to_s)
      missing_headers = mandatory_headers - actual_headers_s
      if missing_headers.any?
        raise "Missing headers: #{missing_headers}. Expected: #{mandatory_headers}, Actual: #{actual_headers_s}"
      end

      # Create a mapping of header names and their indices
      header_mapping = {}
      actual_headers.each_with_index do |header, index|
        header_mapping[header.downcase] = index
      end

      # Symbolize the header names and convert the CSV data to hashes
      csv_data.map do |row|
        row.transform_keys! { |key| key.downcase.to_sym }
      end
    rescue => e
      @project.update(status: 'Error Parsing CSV', error_message: e.message)
      raise e
    end
  end

  def read_and_validate_csv_old(csv)
    entry_dbg
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
      @project.update(status: 'Error Parsing CSV', error_message: e.message)
      raise e
    end
  end

  def summarize_species(csv_data, only_fraxinus: false)
    entry_dbg
    species_counts = Hash.new
    dbg "CSV data: #{csv_data}"
    csv_data.each do |row|
      dbg "Row: #{row}"
      # If the scientific_name is nil, include it in the 'Unspecified' category
      sci_name = row[:scientific_name] || 'Unspecified'
      key = sci_name.downcase.strip

      # If the common_name is nil, include it in the 'Unspecified' category
      common_name = row[:common_name] || 'Unspecified'

      # If only_fraxinus is true, skip the row unless the species starts with either Fraxinus or Chionanthus
      next if only_fraxinus && !row[:scientific_name].to_s.start_with?('Fraxinus', 'Chionanthus')

      unless species_counts[key]
        species_counts[key] = {
          count: 0,
          common: common_name,
          latin: sci_name
        }
      end
      species_counts[key][:count] += 1
    end
    species_counts.sort_by { |common_name, _| common_name }.to_h
  end

  def summarize_dbh(csv_data, only_fraxinus: false)
    entry_dbg
    min_dbh = Float::INFINITY
    max_dbh = -Float::INFINITY
    csv_data.each do |row|
      # If only_fraxinus is true, skip the row unless the species starts with either Fraxinus or Chionanthus
      next if only_fraxinus && !row[:scientific_name].to_s.start_with?('Fraxinus', 'Chionanthus')

      # If row[:dbh] is nil, skip the row
      next if row[:dbh].nil?

      dbh = row[:dbh].to_f
      min_dbh = [min_dbh, dbh].min
      max_dbh = [max_dbh, dbh].max
    end

    { min_dbh: min_dbh, max_dbh: max_dbh }
  end

  def summarize_conditions(csv_data, only_fraxinus: false)
    entry_dbg
    # Initialize tree condition counters
    condition_counts = Hash.new(0)

    dbg "CSV data: #{csv_data}"
    # Iterate through the CSV data
    csv_data.each do |row|
      # If the species is "Vacant", skip the row
      next if row[:scientific_name] == 'Vacant'

      # If the condition is nil, include it in the 'Unspecified' category
      condition_name = row[:condition].nil? ? 'Unspecified' : row[:condition]

      # If only_fraxinus is true, skip the row unless the species starts with either Fraxinus or Chionanthus
      next if only_fraxinus && !row[:scientific_name].to_s.start_with?('Fraxinus', 'Chionanthus')

      condition_name = condition_name.downcase.strip
      condition_counts[condition_name] += 1
    end

    condition_counts
  end

  def count_trees(csv_data, only_fraxinus: false)
    entry_dbg
    begin
      condition_summary = summarize_conditions(csv_data, only_fraxinus: only_fraxinus)
      species_summary = summarize_species(csv_data, only_fraxinus: only_fraxinus)
      dbh_summary = summarize_dbh(csv_data, only_fraxinus: only_fraxinus)
      total_sites =species_summary.values.map { |v| v[:count] }.sum
      {
        "#{only_fraxinus ? 'fraxinus_' : ''}condition_summary": condition_summary,
        "#{only_fraxinus ? 'fraxinus_' : ''}species_summary": species_summary,
        "#{only_fraxinus ? 'fraxinus_' : ''}dbh_summary": dbh_summary,
        "#{only_fraxinus ? 'fraxinus_' : ''}total_sites": total_sites
      }
    rescue => e
      @project.update(status: 'Error Counting Trees', error_message: e.message)
      raise e
    end
  end

end

