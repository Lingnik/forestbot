require 'csv'

class ProcessForestProject < ActiveJob::Base
  queue_as :default

  def perform(project_id)
    project = ForestProject.find(project_id)

    project.update(status: 'Calculating')
    csv_data = read_and_validate_csv(project.csv)
    excellent, good, fair, poor, dead, min_dbh, max_dbh = count_trees(csv_data)

    project.update(status: 'Creating Docs', excellent: excellent, good: good, fair: fair, poor: poor, dead: dead, min_dbh: min_dbh, max_dbh: max_dbh)
    folder_id = create_google_drive_folder(project)
    create_google_spreadsheet(project, folder_id, csv_data)
    create_google_doc(project, folder_id)

    project.update(status: 'Done')
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

  def count_trees(csv_data)
    begin
      # Initialize tree condition counters
      excellent = 0
      good = 0
      fair = 0
      poor = 0
      dead = 0

      # Initialize min and max DBH values
      min_dbh = Float::INFINITY
      max_dbh = -Float::INFINITY

      # Iterate through the CSV data
      csv_data.each do |row|
        # Update tree condition counters
        case row[:condition].downcase
        when 'excellent'
          excellent += 1
        when 'good'
          good += 1
        when 'fair'
          fair += 1
        when 'poor'
          poor += 1
        when 'dead'
          dead += 1
        else
          raise "Invalid tree condition: #{row[:condition]}"
        end

        # Update min and max DBH values
        dbh = row[:dbh].to_f
        min_dbh = [min_dbh, dbh].min
        max_dbh = [max_dbh, dbh].max
      end

      [excellent, good, fair, poor, dead, min_dbh, max_dbh]
    rescue => e
      project.update(status: 'Error Counting Trees', error_message: e.message)
      raise e
    end
  end

  def create_google_drive_folder(project)
    begin
      client = GoogleDriveClient.new

      # Initialize the API client
      client = Google::Apis::DriveV3::DriveService.new
      client.authorization = Google::Auth.get_application_default(
        'https://www.googleapis.com/auth/drive'
      )

      # Create a new Google Drive folder
      folder = Google::Apis::DriveV3::File.new(
        name: "#{project.client_name} - #{project.project_name}",
        mime_type: 'application/vnd.google-apps.folder'
      )

      # Insert the folder into the user's Google Drive
      created_folder = client.create_file(folder)

      # Return the folder ID
      created_folder.id
    rescue => e
      project.update(status: 'Error Creating Folder', error_message: e.message)
      raise e
    end
  end

  def create_google_spreadsheet(project, folder_id, csv_data)
    begin
      # Initialize the API client
      client = Google::Apis::SheetsV4::SheetsService.new
      client.authorization = Google::Auth.get_application_default(
        'https://www.googleapis.com/auth/spreadsheets'
      )

      # Create a new Google Spreadsheet
      spreadsheet = Google::Apis::SheetsV4::Spreadsheet.new(
        properties: {
          title: "#{project.client_name} - #{project.project_name} Spreadsheet"
        },
        sheets: [
          {
            properties: {
              title: 'Data',
              sheet_type: 'GRID'
            }
          }
        ]
      )

      # Insert the spreadsheet into the specified Google Drive folder
      created_spreadsheet = client.create_spreadsheet(spreadsheet, folder_id: folder_id)

      # Write the CSV data to the spreadsheet
      range = 'Data!A1:C'
      value_range = Google::Apis::SheetsV4::ValueRange.new(values: [csv_data.headers] + csv_data.map(&:values))
      client.update_spreadsheet_value(created_spreadsheet.spreadsheet_id, range, value_range, value_input_option: 'RAW')

      # Return the spreadsheet ID
      created_spreadsheet.spreadsheet_id
    rescue => e
      project.update(status: 'Error Creating Spreadsheet', error_message: e.message)
      raise e
    end
  end

  def create_google_doc(project, folder_id)
    begin
      # Initialize the API client
      client = Google::Apis::DocsV1::DocsService.new
      client.authorization = Google::Auth.get_application_default(
        'https://www.googleapis.com/auth/documents'
      )

      # Create a new Google Doc
      doc = Google::Apis::DocsV1::Document.new(
        title: "#{project.client_name} - #{project.project_name} Document"
      )

      # Insert the doc into the specified Google Drive folder
      created_doc = client.create_document(doc, drive_folder_id: folder_id)

      # Update the document with the project data
      # You can use the Google Docs API to replace placeholders in the document
      # with the data from the project.

      # Return the document ID
      created_doc.document_id
    rescue => e
      project.update(status: 'Error Creating Doc', error_message: e.message)
      raise e
    end
  end

end

