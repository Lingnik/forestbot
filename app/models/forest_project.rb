# app/models/forest_project.rb
# frozen_string_literal: true

require "google_drive_client"

# ForestProject is a model for storing information about an urban forest
# collection project. Each is associated with a user, and has a CSV file
# attached. The CSV file is parsed and the tree counts are stored in the
# tree_counts field.
class ForestProject < ApplicationRecord
  belongs_to :user

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
    tree_counts ? tree_counts["species_summary"] || {} : {}
  end

  def condition_summary
    tree_counts ? tree_counts["condition_summary"] || {} : {}
  end

  def dbh_summary
    tree_counts ? tree_counts["dbh_summary"] || {} : {}
  end

  def total_sites
    tree_counts ? tree_counts["total_sites"] || {} : {}
  end

  def fraxinus_species_summary
    tree_counts ? tree_counts["fraxinus_species_summary"] || {} : {}
  end

  def fraxinus_condition_summary
    tree_counts ? tree_counts["fraxinus_condition_summary"] || {} : {}
  end

  def fraxinus_dbh_summary
    tree_counts ? tree_counts["fraxinus_dbh_summary"] || {} : {}
  end

  def fraxinus_total_sites
    tree_counts ? tree_counts["fraxinus_total_sites"] || {} : {}
  end

  def google_folder
    google_drive_folder_id ? "https://drive.google.com/drive/u/2/folders/#{google_drive_folder_id}" : nil
  end

  def google_sheet
    google_spreadsheet_id ? "https://docs.google.com/spreadsheets/d/#{google_spreadsheet_id}/edit#gid=0" : nil
  end

  def google_doc
    google_doc_id ? "https://docs.google.com/document/d/#{google_doc_id}/edit" : nil
  end

  private

  def google_client(user)
    @google_client ||= GoogleDriveClient.new(user)
  end
end
