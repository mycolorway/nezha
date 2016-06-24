require 'spec_helper'

module Nezha
  describe Client do
    let(:access_key) { "D180DF3936BE57AE46EA9BE02C6A01330E6200163E000396" }
    let(:secret_key) { "thebestequipmentiskelensdagger" }
    let(:endpoint) { "http://127.0.0.1:3000" }
    let(:client) { Client.new(access_key, secret_key, endpoint) }

    describe "initialize" do
      let(:endpoint) { "https://fk.zhirenhr.com" }

      context "parameters checking" do
        context "invalid" do

          context "endpoint" do
            it "should raise error" do
              expect { Client.new(access_key, secret_key, nil) }.to raise_error("Invalid Endpoint")
              expect { Client.new(access_key, secret_key, '') }.to raise_error("Invalid Endpoint")
              expect { Client.new(access_key, secret_key, 'fk.zhirenhr.com') }.to raise_error("Invalid Endpoint")
              expect { Client.new(access_key, secret_key, 'https://fk.zhirenhr.com/api?signature=333') }.to raise_error("Invalid Endpoint")
            end
          end
        end

        context "valid" do
          it "should not raise any error" do
            expect { Client.new(access_key, secret_key, endpoint) }.to_not raise_error
          end

          it "set the value" do
            client = Client.new(access_key, secret_key, endpoint)
            expect(client.access_key).to eq(access_key)
            expect(client.secret_key).to eq(secret_key)
            expect(client.endpoint).to eq(endpoint)
          end

          it "set the default value for endpoint" do
            client = Client.new(access_key, secret_key)
            expect(client.endpoint).to eq("https://fk.zhirenhr.com")
          end
        end

      end
    end

    describe "#get" do
      let(:endpoint) { 'http://localhost:3000' }
      let(:access_key) { '83aaa2dc0dc1c4980070ce74b65cca33' }
      let(:secret_key) { 'f161c8796f751111dc267ff8032a6717' }
      let(:token) { 'a3b6cee5473752965c7e695ecb62429a' }
      let(:client) {Client.new(access_key, secret_key, endpoint)}

      context "/time" do
        it "should return current time of server" do
          response = client.get('/api/v1/time')
          # expect(response.body).to eq('')
        end
      end

      context "/companies" do
        it "should return the company by token" do
          response = client.get('/api/v1/company', {  token: token } )
          # expect(ActiveSupport::JSON.decode(response.body)).to eq('')
        end
      end
    end


  end
end
