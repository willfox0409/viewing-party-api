class ErrorSerializer
  def self.format_error(message, status_code)
    {
      message: message,
      status: status_code
    }
  end

  def self.format_errors_array(messages, status_code) #creates an array if there are multiple errors 
    {
      errors: Array(messages).map do |msg|
        { detail: msg }
      end,
      status: status_code
    }
  end
end