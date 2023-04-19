# test/application_system_test_case.rb
# frozen_string_literal: true

require "test_helper"

# ApplicationSystemTestCase is a base class for all system tests.
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
end
