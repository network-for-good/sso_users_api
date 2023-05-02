# frozen_string_literal: true

require "spec_helper"
require 'sso_users_api/manager_job'
require 'sso_users_api/manager'
require 'flexirest'
require 'sso_users_api/logger'
require 'sidekiq/testing'
require 'rspec/sidekiq/helpers/within_sidekiq_retries_exhausted_block'

class DummyUser
  def self.find(id)
  end
end

class CallbackJob
  include Sidekiq::Worker
  def perform(id)
  end
end

RSpec.describe SsoUsersApi::ManagerJob do
  before do
    allow(DummyUser).to receive(:find).and_return(user)
  end

  let(:user) { double('User') }
  let(:callback_job) { CallbackJob }
  let(:callback_job_name) { 'CallbackJob' }
  let(:options) do
    { "on_success_call_back_job_name" => 'CallbackJob' }
  end

  let(:api_manager) { double(:api_manager, call: nil) }

  before do
    allow(SsoUsersApi::Manager).to receive(:new).with(user).and_return(api_manager)
  end

  it 'invokes the API manager' do
    expect(api_manager).to receive(:call)
    subject.perform(1, 'DummyUser', options)
  end

  describe "taking care of callback actions" do
    context 'when a job is passed in as a callback' do
      it 'should enqueue the callback job' do
        Sidekiq::Testing.inline! do
          expect(callback_job).to receive(:perform_async).with(1)
          SsoUsersApi::ManagerJob.perform_async(1, "DummyUser", options)
        end
      end
    end

    context 'when a job is not passed in as a callback' do
      let(:options) { {} }

      it 'should not enqueue the callback job' do
        Sidekiq::Testing.inline! do
          expect(callback_job).to_not receive(:perform_async)
          SsoUsersApi::ManagerJob.perform_async(1, 'DummyUser', options)
        end
      end
    end
  end

  context 'when a Flexirest exception occurs' do
    let(:exception_handler) do
      instance_double('SsoUsersApi::ExceptionHandler')
    end

    let(:exception) do
      SsoUsersApi::RetryableException.new
    end

    before do
      subject.exception_handler = exception_handler
      allow(api_manager).to receive(:call).and_raise(exception)
    end

    context 'that is retryable' do
      before do
        allow(exception_handler).to receive_messages(call: exception)
      end

      it 're-raises error' do
        expect {
          subject.perform(1, 'DummyUser', options)
        }.to raise_error(exception)
      end
    end

    context 'that is ignorable' do
      let(:exception) do
        Flexirest::RequestException.new(status: 503)
      end

      before do
        allow(exception_handler).to receive(:call).and_yield('User already exists')
      end

      it 'does not raise error' do
        expect { subject.perform(1, 'DummyUser', options) }.not_to raise_error
      end
    end

    context 'that is reportable' do
      let(:exception) do
        Flexirest::HTTPBadRequestClientException.new(status: 422)
      end

      before do
        allow(exception_handler).to receive_messages(call: exception)
      end

      it 're-raises error' do
        expect {
          subject.perform(1, 'DummyUser', options)
        }.to raise_error(exception)
      end
    end
  end

  context 'when a record is not found' do
    before do
      allow(DummyUser).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
    end

    it 'does not raise error' do
      expect { subject.perform(1, 'DummyUser', options) }.not_to raise_error
    end
  end

  context 'when retryable exception retries are exhausted' do
    let(:exception_notifier) { double(:exception_notifier, call: nil) }

    let(:retryable_exception) do
      SsoUsersApi::RetryableException.new('ugh')
    end

    let(:original_exception) do
      Flexirest::HTTPServerException.new(status: 503)
    end

    before do
      # small hack because there's no way to set 'cause' manually on an exception,
      # because we are not re-raising it in this test
      allow(retryable_exception).to receive_messages(cause: original_exception)
      subject.exception_notifier = exception_notifier
    end

    it 'reports the original exception to the exception notification service' do
      described_class.within_sidekiq_retries_exhausted_block({}, retryable_exception) {}
      expect(exception_notifier).to have_received(:call).with(original_exception)
    end
  end
end
