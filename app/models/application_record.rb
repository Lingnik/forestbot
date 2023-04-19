# app/models/application_record.rb
# frozen_string_literal: true

# ApplicationRecord is the base class for all models in the application.
# It is an abstract class, meaning that it cannot be instantiated.
# It is used to define methods that are common to all models.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
