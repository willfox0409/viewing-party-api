class ErrorSerializer
  def self.format_error(error)
    {
      message: error.full_messages
    }
  end
end