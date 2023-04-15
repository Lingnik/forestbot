class ForestProject < ApplicationRecord
  belongs_to :user
  has_one :forest_job

  has_one_attached :csv

  validates :client_name, presence: true
  validates :project_name, presence: true
  validates :csv, presence: true

  def tree_counts
    @tree_counts ||= self[:tree_counts]
  rescue JSON::ParserError => e
    raise "Invalid JSON in tree_counts field: #{e.message}"
  end

  def species_summary
    tree_counts['species_summary'] || {}
  end

  def condition_summary
    tree_counts['condition_summary'] || {}
  end

  def dbh_summary
    tree_counts['dbh_summary'] || {}
  end

  def google_sheet
    begin
      id = self.google_spreadsheet_id
      return nil unless id
      @google_sheet ||= GoogleSheet.new(id)
    rescue
      nil
    end
  end

  def google_doc
    begin
    id = self.google_doc_id
    return nil unless id
    @google_doc ||= GoogleDoc.new(id)
    rescue
      nil
    end
  end
end
