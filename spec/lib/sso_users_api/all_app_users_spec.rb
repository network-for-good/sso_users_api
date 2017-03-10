require "rails_helper"

describe SsoUsersApi::AllAppUsers do
  let(:klass) { SsoUsersApi::AllAppUsers }

  let(:all_app_users) { klass.new(user) }
  let(:user) { OpenStruct.new(email: email) }
  let(:email) { "this@that.com" }


  before do
    SsoUsersApi::Base.access_token = "__token__"
  end

  describe ".call" do
    subject { klass.call(user) }

    it "should create a new all_app_users instance, passing in user, and calling call" do
      call_double = double
      expect(call_double).to receive(:call).and_return([])
      expect(klass).to receive(:new).with(user).and_return(call_double)
      subject
    end
  end

  describe "#call" do
    subject { all_app_users.call }

    it "should call the UsersApplicationAccessList list method" do
      expect(SsoUsersApi::UserApplicationAccessList).to receive(:list).with(email: user.email).and_return(double(items: []))
      subject
    end

    context 'when the results of the user application access list returns a 404, not found response' do
      it "should return an empty array" do
        VCR.use_cassette('user_with_no_access_records') do
          expect(subject).to eq([])
        end
      end
    end

    context 'when the results of the user application access call returns results, with at least one record' do
      let(:email) { "nfgcvlx+27-1095214D@gmail.com" }
      it "should return an empty array" do
        VCR.use_cassette('user_with_active_gp_access_records') do
          expect(subject).to be_present
        end
      end
    end

  end
end