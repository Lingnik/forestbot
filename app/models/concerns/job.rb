# frozen_string_literal: true

class Job < ApplicationRecord
  belongs_to :project

  # Add your job validation logic and custom methods here

end
