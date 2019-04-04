require "spec_helper"
require 'sso_users_api/manager_job'
require 'sso_users_api/manager'
require 'flexirest'

class DummyUser
  def self.find(id)

  end
end

describe SsoUsersApi::ManagerJob do
  before do
    allow(DummyUser).to receive(:find).and_return(user)
  end
  let(:user) { double }
  let(:callback_job) { double('job_name', perform_later: nil)}
  let(:callback_job_name) { double('job', constantize: callback_job) }
  let(:options) { { on_success_call_back_job_name: callback_job_name }}

  context "and the passed class name belongs to a valid object" do
    context 'when calling the manager service raises an error' do
      it "should put the job back on the queue an increment the counter" do
        manager = double
        expect(manager).to receive(:call).and_raise(Flexirest::TimeoutException.new("Timed out"))
        expect(SsoUsersApi::Manager).to receive(:new).with(user).and_return(manager)
        expect(SsoUsersApi::ManagerJob).to receive(:perform_later).with(1, "DummyUser", 1, {})
        SsoUsersApi::ManagerJob.perform_now(1, "DummyUser")
      end

      context "and we have already attempted twice" do
        it "should not attempt a fourth time but should reraise the error" do
          manager = double
          expect(manager).to receive(:call).and_raise(Flexirest::TimeoutException.new("Timed out"))
          expect(SsoUsersApi::Manager).to receive(:new).with(user).and_return(manager)
          expect(SsoUsersApi::ManagerJob).not_to receive(:perform_later)

          expect { SsoUsersApi::ManagerJob.perform_now(1, "DummyUser", 2) }.to raise_error(Flexirest::TimeoutException)
        end
      end
    end
  end

  context "taking care of callback actions" do
    before do
      manager = double
      expect(manager).to receive(:call)
      expect(SsoUsersApi::Manager).to receive(:new).with(user).and_return(manager)
    end

    context 'when a job is passed in as a callback' do
      it 'should enqueue the callback job' do
        expect(callback_job).to receive(:perform_later).with(1)
        SsoUsersApi::ManagerJob.perform_now(1, "DummyUser", 0, options)
      end

      context "when there is an error" do
        let(:error) { StandardError }
        before do
          allow(callback_job).to receive(:perform_later).and_raise(error)
        end

        it 'logs properly' do
          expect(Rails.logger).to receive(:error).with("Failed to execute: #{callback_job_name}, error: #{error}")
          SsoUsersApi::ManagerJob.perform_now(1, "DummyUser", 0, options)
        end
      end
    end

    context 'when a job is not passed in as a callback' do
      let(:options) { {} }

      it 'should not enqueue the callback job' do
        expect(callback_job).to_not receive(:perform_later)
        SsoUsersApi::ManagerJob.perform_now(1, "DummyUser", 0, options)
      end
    end
  end


end
