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

  context "and the passed class name belongs to a valid object" do
    context 'when calling the manager service raises an error' do
      it "should put the job back on the queue an increment the counter" do
        manager = double
        expect(manager).to receive(:call).and_raise(Flexirest::TimeoutException.new("Timed out"))
        expect(SsoUsersApi::Manager).to receive(:new).with(user).and_return(manager)
        expect(SsoUsersApi::ManagerJob).to receive(:perform_later).with(1, "DummyUser", 1)
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
end