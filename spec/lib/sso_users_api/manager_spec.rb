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

shared_examples_for "calling the update endpoint" do
  let(:response) { subject }

  it "should attempt to update the user on the SSO server" do
    allow(SsoUsersApi::User).to receive(:new).with(username: user.email).and_return(search_double)
    allow(search_double).to receive(:search).and_return(flexirest_find_response)
    expect(update_double).to receive(:update).and_return(flexirest_response)
    expect(SsoUsersApi::User).to receive(:new).with(id: sso_id, first_name: user.first_name, last_name: user.last_name, username: user.email, claims: claims).and_return(update_double)
    subject
  end

  it "should return an updated user from the sso server" do
    expect(response.FirstName).to eq(user.first_name)
    expect(response.ID).not_to be_nil
  end
end

shared_examples_for "calling the create endpoint" do
  let(:response) { subject }

  it "should attempt to create the user on the SSO server" do
    allow(SsoUsersApi::User).to receive(:new).with(username: user.email).and_return(search_double)
    allow(search_double).to receive(:search).and_return(flexirest_find_response)
    expect(create_double).to receive(:create).and_return(flexirest_response)
    expect(SsoUsersApi::User).to receive(:new).with(first_name: user.first_name, last_name: user.last_name, username: user.email, claims: claims).and_return(create_double)
    subject
  end

  it "should return a newly created user from the sso server" do
    expect(response.FirstName).to eq(user.first_name)
    expect(response.ID).not_to be_nil
  end
end

shared_examples_for "updating the sso_id" do
  it "should update the user's sso_id" do
    expect{ subject }.to change { user.sso_id }.from(nil).to(sso_id_value)
  end
end

describe SsoUsersApi::Manager do
  let(:search_double) { double }
  let(:create_double) { double }
  let(:update_double) { double }
  let(:sso_id_value) { "0bd1b7b1-ba47-49d3-8210-ad01e17bb5a2" }
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
                                            id: sso_id_value) }

  describe "#call" do
    subject do
      SsoUsersApi::Base.access_token = "__dummy_token__"
      VCR.use_cassette("user/#{api_request_type}", allow_playback_repeats: true) do
        manager.call
      end
    end

    describe "A user that responds to sso_id" do
      let(:user) { DummyUserWithSsoID.new(params.merge(sso_id: sso_id)) }

      context "With no sso_id and an existing user" do
        let(:sso_id) { nil }
        let(:api_request_type) { "create_with_user_found" }
        let(:flexirest_find_response) { OpenStruct.new(items: [flexirest_response]) }
        it_behaves_like "calling the update endpoint"
        it_behaves_like "updating the sso_id"
      end

      context "With no sso_id and no existing user" do
        let(:sso_id) { nil }
        let(:api_request_type) { "create_with_no_user_found" }
        let(:flexirest_find_response) { OpenStruct.new(items: []) }
        it_behaves_like "calling the create endpoint"
        it_behaves_like "updating the sso_id"
      end

      context "With an sso_id" do
        let(:sso_id) { sso_id_value }
        let(:api_request_type) { "create_with_user_found" }
        let(:flexirest_find_response) { OpenStruct.new(items: [flexirest_response]) }
        it_behaves_like "calling the update endpoint"
      end

      context "when SsoUsersApi create method didn't return an ID value" do
        before do
          allow(SsoUsersApi::User).to receive(:new).once.with(username: user.email).and_return(search_double, search_double2)
          allow(search_double).to receive(:search).and_return(flexirest_find_response)
          allow(search_double2).to receive(:search).and_return(flexirest_find_response2)

          allow(SsoUsersApi::User).to receive(:new).once.with(first_name: user.first_name, last_name: user.last_name, username: user.email, claims: claims).and_return(create_double2)
          allow(create_double2).to receive(:create).and_return(flexirest_response)
        end

        let(:flexirest_response) do
          OpenStruct.new(
            first_name: user.first_name,
            last_name: user.last_name,
            email: user.email
          )
        end
        let(:create_double2) { double }
        let(:search_double2) { double }
        let(:sso_id) { nil }
        let(:api_request_type) { "create_with_user_found" }
        let(:flexirest_find_response) { OpenStruct.new(items: []) }
        let(:flexirest_find_response2) { OpenStruct.new(items: [flexirest_response]) }
        let(:flexirest_response2) { OpenStruct.new }

        it "queries for User with search and updates the sso_id" do
          expect(create_double).to receive(:create).and_return(flexirest_response2)
          expect(SsoUsersApi::User).to receive(:new).with(first_name: user.first_name, last_name: user.last_name, username: user.email, claims: claims).and_return(create_double)

          subject
        end
      end
    end

    describe "A user that doesn't respond to sso_id" do
      let(:user) { DummyUserWithoutSsoID.new(params) }
      let(:sso_id) { nil }

      let(:api_request_type) { "create_with_no_user_found" }
      let(:flexirest_find_response) { OpenStruct.new(items: []) }
      it_behaves_like "calling the create endpoint"
    end
  end
end
