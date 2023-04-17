# app/services/google_drive_client.rb

# frozen_string_literal: true

require 'google/apis/drive_v3'
require 'google/apis/sheets_v4'
require 'google/apis/docs_v1'
require 'google/api_client/client_secrets'

class GoogleDriveClient

  def initialize(user)
    entry_dbg
    @user = user
    user.refresh_tokens!

    @sheets_service = Google::Apis::SheetsV4::SheetsService.new
    @sheets_service.authorization = google_secret.to_authorization
    #@sheets_service.authorization.refresh!

    @drive_service = Google::Apis::DriveV3::DriveService.new
    @drive_service.authorization = google_secret.to_authorization
    #@drive_service.authorization.refresh!

    @docs_service = Google::Apis::DocsV1::DocsService.new
    @docs_service.authorization = google_secret.to_authorization
    #@docs_service.authorization.refresh!

  end

  # 0ABpZS99k3z4gUk9PVA

  def url_for_file(file_id)
    entry_dbg
    @drive_service.get_file(
      file_id,
      supports_all_drives: true,
      fields: 'webViewLink'
    ).web_view_link
  end

  def get_file(file_id)
    entry_dbg
    @drive_service.get_file(
      file_id,
      supports_all_drives: true,
    )
  end

  def create_folder(name, parent_id)
    entry_dbg
    folder = Google::Apis::DriveV3::File.new(
      name: name,
      mime_type: 'application/vnd.google-apps.folder',
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
      name: name,
      parents: [parent_id],
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
    old_parents = old_file&.parents&.join(',') || ''
    @drive_service.update_file(
      file_id,
      remove_parents: old_parents,
      add_parents: "#{parent_id}",
      supports_all_drives: true
    )
  end

  def append_csv_to_spreadsheet(spreadsheet_id, csv_data)
    entry_dbg
    data_array = convert_csv_data_to_2d_array(csv_data)

    data = [
      {
        range: 'A1',
        values: data_array
      }
    ]

    batch_update_values = Google::Apis::SheetsV4::BatchUpdateValuesRequest.new(
      data: data,
      value_input_option: 'USER_ENTERED'
    )
    @sheets_service.batch_update_values(
      spreadsheet_id,
      batch_update_values
    )
  end

  def convert_csv_data_to_2d_array(csv_data)
    # Convert the array of hashes into a 2D array
    headers = csv_data.first.keys
    data_array = csv_data.map { |row| row.values }

    # Add headers as the first row in the 2D array
    data_array.unshift(headers)

    data_array
  end

  def replace_placeholders_in_doc_with_values(document_id, replacements)
    entry_dbg
    # replacements looks like:
    # [
    #   { "{{first_name}}": "John" },
    # ]
    edits = []
    replacements.each do |replacement|
      replacement.each do |key, value|
        edits << {
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
    batch_update = Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests: edits)
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
    { "web" =>
        { "access_token" => @user.google_token,
          "refresh_token" => @user.google_refresh_token,
          "client_id" => ENV['GOOGLE_CLIENT_ID'],
          "client_secret" => ENV['GOOGLE_CLIENT_SECRET'],
          "grant_type" => "refresh_token"
        }
    }
  end
end
