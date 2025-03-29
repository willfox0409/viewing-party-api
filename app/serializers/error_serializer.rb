class ErrorSerializer
  def self.format_error(message, status_code)
    {
      message: message,
      status: status_code
    }
  end
end