require "spec_helper"
require 'sso_users_api/manager_job'
require 'sso_users_api/manager'
require 'flexirest'
require 'sso_users_api/logger'
require 'sidekiq/testing'

class DummyUser
  def self.find(id)

  end
end

class CallbackJob
  include Sidekiq::Worker
  def perform(id)
  end
end

describe SsoUsersApi::ManagerJob do
  before do
    allow(DummyUser).to receive(:find).and_return(user)
  end

  let(:user) { double('User') }
  let(:callback_job) { CallbackJob }
  let(:callback_job_name) { 'CallbackJob' }
  let(:options) { { on_success_call_back_job_name: 'CallbackJob' }}

  describe "taking care of callback actions" do
    before do
      manager = double
      allow(manager).to receive(:call)
      allow(SsoUsersApi::Manager).to receive(:new).with(user).and_return(manager)
    end

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
          SsoUsersApi::ManagerJob.perform_async(1, "DummyUser", options)
        end
      end
    end
  end
end
