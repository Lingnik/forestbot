# frozen_string_literal: true

class GoogleDriveClient


  def initialize(authorization)
    client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
    token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new)

    @Sheets = Google::Apis::SheetsV4::SheetsService.new
    oauth_scope = 'https://www.googleapis.com/auth/spreadsheets'
    authorizer = Google::Auth::UserAuthorizer.new(client_id, oauth_scope, token_store)
    @Sheets.authorization = {
      client_id: client_id,
      scope: oauth_scope,
    }
    @Drive = Google::Apis::DriveV3::DriveService.new
    @Docs = Google::Apis::DocsV1::DocsService.new

    drive = Google::Apis::DriveV3::DriveService.new
    drive.authorization = credentials_for()
    @drive_service = drive

    @drive_service = Google::Apis::DriveV3::DriveService.new.tap do |drive|
      drive.authorization = authorization
    end
    @sheets_service = Google::Apis::SheetsV4::SheetsService.new.tap do |sheets|
      sheets.authorization = authorization
    end
    @docs_service = Google::Apis::DocsV1::DocsService.new.tap do |docs|
      docs.authorization = authorization
    end
  end

  def credentials_for(oauth_scope)

  end

  def x(y)

    @result = drive.list_files(page_size: 10,
                               fields: 'files(name,modified_time,web_view_link),next_page_token')
  end

  def create_folder(name, parent_id)
    folder = Google::Apis::DriveV3::File.new(
      name: name,
      mime_type: 'application/vnd.google-apps.folder',
      parents: [parent_id]
    )
    @drive_service.create_file(folder)
  end

  def create_spreadsheet_from_template(name, parent_id, template_id)
    spreadsheet = Google::Apis::SheetsV4::SheetsService.new(
      properties: {
        title: name
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
    @sheets_service.create_spreadsheet(spreadsheet, fields: 'spreadsheetId', upload_source: StringIO.new, content_type: 'application/json', template_id: template_id)
  end

  def create_document_from_template(name, parent_id, template_id)
    document = Google::Apis::DocsV1::Document.new(
      title: name
    )
    @docs_service.create_document(document, fields: 'documentId', upload_source: StringIO.new, content_type: 'application/json', template_id: template_id)
  end

  def append_csv_to_spreadsheet(spreadsheet_id, csv_data)
    @sheets_service.batch_update_spreadsheet(spreadsheet_id, Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(requests: [
      Google::Apis::SheetsV4::Request.new(
        append_cells: Google::Apis::SheetsV4::AppendCellsRequest.new(
          sheet_id: 0,
          rows: [
            Google::Apis::SheetsV4::RowData.new(
              values: [
                Google::Apis::SheetsV4::ExtendedValue.new(
                  string_value: csv_data
                )
              ]
            )
          ],
          fields: '*'
        )
      )
    ]))
  end
end
