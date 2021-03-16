# frozen_string_literal: true

module SsoUsersApi
  # Represents an expected exception, such as occasional API timeout errors
  # or rate-limiting error responses. These exceptions are not indicative of
  # bugs and should be handled by Sidekiq's built-in error-handling and retrying.
  # @see SsoUsersApi::ExceptionHandler
  class RetryableException < StandardError
  end
end
