class Object

  private

  def dbg(message)
    if Rails.env.development? || ENV['DEBUG'] == '*'
      puts "     d #{message}"
    end
  end

  def entry_dbg
    if Rails.env.development? || ENV['DEBUG'] == '*'
      caller_location = caller_locations(1, 1)[0]
      path = caller_location.path.gsub("#{Rails.root}/", "")
      method_name = caller_location.label
      warn "     - #{path}:#{caller_location.lineno}:in #{method_name}"
    end
  end

end
