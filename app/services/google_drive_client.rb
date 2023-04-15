# frozen_string_literal: true
require 'google/apis/drive_v3'
require 'google/apis/sheets_v4'
require 'google/apis/docs_v1'


class GoogleDriveClient

  def initialize(credentials)

    @sheets_service = Google::Apis::SheetsV4::SheetsService.new
    @sheets_service.authorization = credentials

    @drive_service = Google::Apis::DriveV3::DriveService.new
    @drive_service.authorization = credentials

    @docs_service = Google::Apis::DocsV1::DocsService.new
    @docs_service.authorization = credentials
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
