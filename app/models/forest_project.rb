# app/models/forest_project.rb

require 'google_drive_client'

class ForestProject < ApplicationRecord
  belongs_to :user
  has_one :forest_job

  has_one_attached :csv

  validates :client_name, presence: true
  validates :project_name, presence: true
  validates :project_date, presence: true
  validates :csv, presence: true

  def tree_counts
    @tree_counts ||= self[:tree_counts]
  rescue JSON::ParserError => e
    raise "Invalid JSON in tree_counts field: #{e.message}"
  end

  def species_summary
    return {} unless tree_counts
    tree_counts['species_summary'] || {}
  end

  def condition_summary
    return {} unless tree_counts
    tree_counts['condition_summary'] || {}
  end

  def dbh_summary
    return {} unless tree_counts
    tree_counts['dbh_summary'] || {}
  end

  def total_sites
    return {} unless tree_counts
    tree_counts['total_sites'] || {}
  end

  def fraxinus_species_summary
    return {} unless tree_counts
    tree_counts['fraxinus_species_summary'] || {}
  end

  def fraxinus_condition_summary
    return {} unless tree_counts
    tree_counts['fraxinus_condition_summary'] || {}
  end

  def fraxinus_dbh_summary
    return {} unless tree_counts
    tree_counts['fraxinus_dbh_summary'] || {}
  end

  def fraxinus_total_sites
    return {} unless tree_counts
    tree_counts['fraxinus_total_sites'] || {}
  end

  def google_folder
    entry_dbg
    id = self.google_drive_folder_id
    return nil unless id
    "https://drive.google.com/drive/u/2/folders/#{id}"
  end

  def google_sheet
    entry_dbg
    id = self.google_spreadsheet_id
    return nil unless id
    "https://docs.google.com/spreadsheets/d/#{id}/edit#gid=0"
  end

  def google_doc
    entry_dbg
    id = self.google_doc_id
    return nil unless id
    "https://docs.google.com/document/d/#{id}/edit"
  end

  private

  def google_client(user)
    entry_dbg
    @google_client ||= GoogleDriveClient.new(user)
  end
end
