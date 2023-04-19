# app/services/google_drive_client.rb
# frozen_string_literal: true

require "google/apis/drive_v3"
require "google/apis/sheets_v4"
require "google/apis/docs_v1"
require "google/api_client/client_secrets"

# GoogleDriveClient is a wrapper around the Google Drive API,
# providing methods for interacting with the API, and handling
# secrets and requesting token refreshes.
class GoogleDriveClient
  def initialize(user)
    entry_dbg
    @user = user
    user.refresh_tokens!

    @sheets_service = Google::Apis::SheetsV4::SheetsService.new
    @sheets_service.authorization = google_secret.to_authorization
    # @sheets_service.authorization.refresh!

    @drive_service = Google::Apis::DriveV3::DriveService.new
    @drive_service.authorization = google_secret.to_authorization
    # @drive_service.authorization.refresh!

    @docs_service = Google::Apis::DocsV1::DocsService.new
    @docs_service.authorization = google_secret.to_authorization
    # @docs_service.authorization.refresh!
  end

  # 0ABpZS99k3z4gUk9PVA

  def url_for_file(file_id)
    entry_dbg
    @drive_service.get_file(
      file_id,
      supports_all_drives: true,
      fields: "webViewLink"
    ).web_view_link
  end

  def get_file(file_id)
    entry_dbg
    @drive_service.get_file(
      file_id,
      supports_all_drives: true
    )
  end

  def create_folder(name, parent_id)
    entry_dbg
    folder = Google::Apis::DriveV3::File.new(
      name:,
      mime_type: "application/vnd.google-apps.folder",
      parents: [parent_id],
      supports_all_drives: true,
      include_items_from_all_drives: true,
      supportsAllDrives: true
    )
    @drive_service.create_file(folder, supports_all_drives: true)
  end

  def copy_file(file_id, name, parent_id)
    entry_dbg
    file = Google::Apis::DriveV3::File.new(
      name:,
      parents: [parent_id]
    )
    new_file = @drive_service.copy_file(
      file_id,
      file,
      supports_all_drives: true
    )
    move_file(new_file.id, parent_id)
  end

  def move_file(file_id, parent_id)
    entry_dbg
    old_file = get_file(file_id)
    old_parents = old_file&.parents&.join(",") || ""
    @drive_service.update_file(
      file_id,
      remove_parents: old_parents,
      add_parents: parent_id.to_s,
      supports_all_drives: true
    )
  end

  def append_csv_to_spreadsheet(spreadsheet_id, csv_data)
    entry_dbg
    data_array = convert_csv_data_to_2d_array(csv_data)

    data = [
      {
        range: "A1",
        values: data_array
      }
    ]

    batch_update_values = Google::Apis::SheetsV4::BatchUpdateValuesRequest.new(
      data:,
      value_input_option: "USER_ENTERED"
    )
    @sheets_service.batch_update_values(
      spreadsheet_id,
      batch_update_values
    )
  end

  def convert_csv_data_to_2d_array(csv_data)
    # Convert the array of hashes into a 2D array
    headers = csv_data.first.keys
    data_array = csv_data.map { |row| row.values } # rubocop:disable Style/SymbolProc

    # Add headers as the first row in the 2D array
    data_array.unshift(headers)

    data_array
  end

  def replace_doc_placeholders(document_id, replacements)
    entry_dbg
    # replacements looks like:
    # [
    #   { '{{first_name}}': 'John' },
    # ]
    requests = []
    replacements.each do |replacement|
      replacement.each do |key, value|
        requests << {
          replace_all_text: {
            contains_text: {
              text: key,
              match_case: false
            },
            replace_text: value
          }
        }
      end
    end
    batch_update = Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests:)
    @docs_service.batch_update_document(document_id, batch_update)
  end

  def insert_table_into_doc(document_id, csv_data)
    entry_dbg
    data_array = convert_csv_data_to_2d_array(csv_data)

    # Insert a new table at the end of the document
    table_request = Google::Apis::DocsV1::InsertTableRequest.new
    table_request.end_of_segment_location = ""
    table_request.rows = data_array.length
    table_request.columns = data_array[0].length
    request = Google::Apis::DocsV1::Request.new
    request.insert_table = table_request
    batch_update = Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests: [request])
    @docs_service.batch_update_document(document_id, batch_update)

    # Get the last element of the document, which should be the table
    document = @docs_service.get_document(document_id)
    body = document.body
    # iterate from the end of document.body.content until we find a StructuralElement with a table attribute
    table_element = body.content.reverse.find { |element| element.table } # rubocop:disable Style/SymbolProc
    table = table_element.table

    # Insert the data into the table, working from the bottom right cell in reverse-order
    # so that we don't have to worry about the indexes changing as we insert text
    batch = []
    row_idx = data_array.length - 1
    table.table_rows.reverse_each do |row|
      cell_idx = data_array[row_idx].length - 1
      row.table_cells.reverse_each do |cell|
        # cell_start_index = cell.content[0].paragraph.elements[0].start_index
        cell_end_index = cell.content[0].paragraph.elements[0].end_index
        cell_request = {
          insert_text: {
            text: data_array[row_idx][cell_idx].to_s || "-",
            location: {
              index: cell_end_index - 1
            }
          }
        }
        batch << cell_request
        cell_idx -= 1
      end
      # noinspection RubyUnusedLocalVariable
      row_idx -= 1
    end

    batch_update = Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests: batch)
    @docs_service.batch_update_document(document_id, batch_update)
  end

  private

  def google_secret
    entry_dbg
    Google::APIClient::ClientSecrets.new(
      secret_hash
    )
  end

  def secret_hash
    entry_dbg
    {
      "web" => {
        "access_token" => @user.google_token,
        "refresh_token" => @user.google_refresh_token,
        "client_id" => ENV.fetch("GOOGLE_CLIENT_ID"),
        "client_secret" => ENV.fetch("GOOGLE_CLIENT_SECRET"),
        "grant_type" => "refresh_token"
      }
    }
  end
end
