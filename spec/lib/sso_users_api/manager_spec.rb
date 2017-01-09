require 'rails_helper'

class DummyUserWithoutSsoID
  attr_accessor :id, :first_name, :last_name, :email

  def initialize(args)
    args.each do |arg, value|
     self.send("#{arg}=", value)
    end
  end

  def nfg_account_id
    "1230456"
  end

  def update(hsh)
    hsh.each do |key, value|
      self.send("#{key}=", value)
    end
  end
end

class DummyUserWithSsoID < DummyUserWithoutSsoID
  attr_accessor :sso_id

end

shared_examples_for "a new sso user request" do
  it "should attempt to create the user on the SSO server" do
    create_double = double
    expect(create_double).to receive(:create).and_return(flexirest_response)
    expect(SsoUsersApi::User).to receive(:new).with(first_name: user.first_name, last_name: user.last_name, username: user.email, claims: claims).and_return(create_double)
    subject
  end

  it "should return a newly created user from the sso server" do
    response = subject
    expect(response.FirstName).to eq(user.first_name)
    expect(response.ID).not_to be_nil
  end
end

describe SsoUsersApi::Manager do
  let(:user) { DummyUserWithoutSsoID.new(params) }
  let(:params) { {
                    first_name: "John",
                    last_name: "Smith",
                    email: "john@smith.com"
                  } }
  let(:manager) { SsoUsersApi::Manager.new(user) }
  let(:claims) { [ { type: "nfg_account", value: user.nfg_account_id }] }
  let(:flexirest_response) { OpenStruct.new(first_name: user.first_name,
                                            last_name: user.last_name,
                                            email: user.email,
                                            id: "0bd1b7b1-ba47-49d3-8210-ad01e17bb5a2") }

  describe "#call" do
    subject do
      SsoUsersApi::Base.access_token = "__dummy_token__"
      VCR.use_cassette "user/#{api_request_type}" do
        manager.call
      end
    end

    let(:api_request_type) { "create" }

    context "when the user does not respond to sso_id" do
      it_behaves_like "a new sso user request"
    end

    context "when the user does respond to sso_id" do
      let(:user) { DummyUserWithSsoID.new(params.merge(sso_id: sso_id)) }

      context "and the sso id is nil" do
        let(:sso_id) { nil }

        it_behaves_like "a new sso user request"

        it "should update the user's sso_id" do
          expect{ subject }.to change { user.sso_id }.from(nil).to("0bd1b7b1-ba47-49d3-8210-ad01e17bb5a2")
        end
      end

      context "and the sso id is not blank" do
        let(:api_request_type) { "update" }

        let(:sso_id) { "0bd1b7b1-ba47-49d3-8210-ad01e17bb5a2" }
        it "should attempt to update the user on the SSO server" do
          update_double = double
          expect(update_double).to receive(:update).and_return(flexirest_response)
          expect(SsoUsersApi::User).to receive(:new).with(id: sso_id, first_name: user.first_name, last_name: user.last_name, username: user.email, claims: claims).and_return(update_double)
          subject
        end

        it "should return a updated user from the sso server" do
          response = subject
          expect(response.FirstName).to eq(user.first_name)
          expect(response.ID).not_to be_nil
        end
      end
    end

  end
end