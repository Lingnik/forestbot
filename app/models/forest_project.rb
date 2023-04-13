class ForestProject < ApplicationRecord
  belongs_to :user
  has_one :forest_job

  has_one_attached :csv

  validates :client_name, presence: true
  validates :project_name, presence: true
  validates :csv, presence: true

  # Add any additional validation logic or custom methods as needed

end
