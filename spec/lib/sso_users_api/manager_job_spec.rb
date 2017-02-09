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
    context "when no count value is included" do
      it "should call the Manager service" do
        expect(SsoUsersApi::Manager).to receive(:new).with(user).and_return(double(call: true))
        SsoUsersApi::ManagerJob.perform_now(1, "DummyUser")
      end
    end

    context "when count value is less then 3" do
      it "should call the Manager service" do
        expect(SsoUsersApi::Manager).to receive(:new).with(user).and_return(double(call: true))
        SsoUsersApi::ManagerJob.perform_now(1, "DummyUser", 2)
      end
    end

    context 'when the count value is 3' do
      it "should not call the manager service" do
        expect(SsoUsersApi::Manager).to receive(:new).never
        SsoUsersApi::ManagerJob.perform_now(1, "DummyUser", 3)
      end
    end

    context 'when calling the manager service raises an error' do
      it "should put the job back on the queue an increment the counter" do
        expect(SsoUsersApi::Manager).to receive(:new).with(user).and_raise(Flexirest::TimeoutException.new("Timed out"))
        expect(SsoUsersApi::ManagerJob).to receive(:perform_later).with(1, "DummyUser", 1)
        SsoUsersApi::ManagerJob.perform_now(1, "DummyUser")
      end
    end
  end
end