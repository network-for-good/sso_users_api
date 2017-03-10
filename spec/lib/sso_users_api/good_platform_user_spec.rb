require "rails_helper"

describe SsoUsersApi::GoodPlatformUser do
  let(:klass) { SsoUsersApi::GoodPlatformUser }

  let(:good_platform_user) { klass.new(user) }
  let(:user) { OpenStruct.new(email: email) }
  let(:email) { "this@that.com" }


  before do
    SsoUsersApi::Base.access_token = "__token__"
  end

  describe ".call" do
    subject { klass.call(user) }

    it "should create a new good_platform_user instance, passing in user, and calling call" do
      call_double = double
      expect(call_double).to receive(:call).and_return([])
      expect(klass).to receive(:new).with(user).and_return(call_double)
      subject
    end
  end

  describe "#call" do
    subject { good_platform_user.call }

    it "should call the UsersApplicationAccessList list method" do
      expect(SsoUsersApi::AllAppUsers).to receive(:call).with(user).and_return([])
      subject
    end

    context 'when the results of the user application access list returns a 404, not found response' do
      it "should return an empty array" do
        VCR.use_cassette('user_with_no_access_records') do
          expect(subject).to eq([])
        end
      end
    end

    context 'when the results of the user application access returns results, but has no gp records' do
      let(:email) { "tom@givecorps.com" }
      it "should return an empty array" do
        VCR.use_cassette('user_with_access_records_but_no_gp_records') do
          expect(subject).to eq([])
        end
      end
    end

    context 'when the results of the user application access returns results, with gp records, but the user is not active' do
      let(:email) { "nfgcvlx+27-1095214D@gmail.com" }
      it "should return an empty array" do
        VCR.use_cassette('user_with_gp_access_records_all_are_inactive') do
          expect(subject).to eq([])
        end
      end
    end

    context 'when the results of the user application access call returns results, with gp records, but the organization is not active' do
      let(:email) { "nfgcvlx+27-1095214D@gmail.com" }
      it "should return an empty array" do
        VCR.use_cassette('user_with_gp_access_records_all_orgs_are_inactive') do
          expect(subject).to eq([])
        end
      end
    end

    context 'when the results of the user application access call returns results, with at least one active gp ' do
      let(:email) { "nfgcvlx+27-1095214D@gmail.com" }
      it "should return an empty array" do
        VCR.use_cassette('user_with_active_gp_access_records') do
          expect(subject).to be_present
        end
      end
    end

  end
end