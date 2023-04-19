# config/initializers/debug.rb
# frozen_string_literal: true

# This adds debugging methods to the Object class.  It is intended to be used
# in development and test environments.  It is not intended to be used in
# production environments.
#
# Set the DEBUG environment variable to '*' to enable debugging.
class Object
  private

  def dbg(message)
    return unless Rails.env.development? || ENV.fetch("DEBUG", "") == "*"
    Rails.logger.debug { "     d #{message}" }
  end

  def entry_dbg
    return unless Rails.env.development? || ENV.fetch("DEBUG", "") == "*"
    caller_location = caller_locations(1, 1)[0]
    path = caller_location.path.gsub("#{Rails.root}/", "") # rubocop:disable Rails/FilePath
    method_name = caller_location.label
    warn "     - #{path}:#{caller_location.lineno}:in #{method_name}"
  end
end
