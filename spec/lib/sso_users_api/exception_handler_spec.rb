# frozen_string_literal: true

require 'spec_helper'
require 'sso_users_api/exception_handler'

RSpec.describe SsoUsersApi::ExceptionHandler do
  shared_examples 'ignorable exception handling' do
    it 'yields a log message' do
      expect { |b|
        subject.call(exception, &b)
      }.to yield_with_args(an_instance_of(String))
    end
  end

  shared_examples 'retryable exception handling' do
    it 'does not yield a log message' do
      expect { |b|
        subject.call(exception, &b)
      }.not_to yield_control
    end

    it 'returns an instance of SsoUsersApi::RetryableException' do
      expect(subject.call(exception)).to be_an_instance_of(SsoUsersApi::RetryableException)
    end
  end

  shared_examples 'reportable exception handling' do
    it 'does not yield a log message' do
      expect { |b|
        subject.call(exception, &b)
      }.not_to yield_control
    end

    it 'returns the original exception instance' do
      expect(subject.call(exception)).to eq(exception)
    end
  end

  context 'with a API timeout exception' do
    let(:exception) do
      Flexirest::TimeoutException.new
    end

    include_examples 'retryable exception handling'
  end

  context 'with an API server exception' do
    let(:exception) do
      Flexirest::HTTPServerException.new(status: 503)
    end

    include_examples 'retryable exception handling'
  end

  context 'with "User already exists" client exception' do
    let(:exception) do
      Flexirest::HTTPClientException.new(raw_response: 'User already exists')
    end

    include_examples 'ignorable exception handling'
  end

  context 'with "Email already in use" client exception' do
    let(:exception) do
      Flexirest::HTTPClientException.new(raw_response: 'Email already in use')
    end

    include_examples 'ignorable exception handling'
  end

  context 'with a reportable exception' do
    let(:exception) do
      Flexirest::HTTPBadRequestClientException.new(status: 422)
    end

    include_examples 'reportable exception handling'
  end
end
