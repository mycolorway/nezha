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
              expect { Client.new(access_key: access_key, secret_key: secret_key, endpoint: nil) }.to raise_error("Invalid Endpoint")
              expect { Client.new(access_key: access_key, secret_key: secret_key, endpoint: '') }.to raise_error("Invalid Endpoint")
              expect { Client.new(access_key: access_key, secret_key: secret_key, endpoint: 'fk.zhirenhr.com') }.to raise_error("Invalid Endpoint")
              expect { Client.new(access_key: access_key, secret_key: secret_key, endpoint: 'https://fk.zhirenhr.com/api?signature=333') }.to raise_error("Invalid Endpoint")
            end
          end
        end

        context "valid" do
          it "should not raise any error" do
            expect { Client.new(access_key: access_key, secret_key: secret_key, endpoint: endpoint) }.to_not raise_error
          end

          it "set the value" do
            client = Client.new(access_key: access_key, secret_key: secret_key, endpoint: endpoint)
            expect(client.access_key).to eq(access_key)
            expect(client.secret_key).to eq(secret_key)
            expect(client.endpoint).to eq(endpoint)
          end

          it "set the default value for endpoint" do
            client = Client.new(access_key: access_key, secret_key: secret_key)
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
      let(:client) {Client.new(access_key: access_key, secret_key: secret_key, endpoint: endpoint)}

      context "/time" do
        let(:response_body) { "{\"timestamp\":1466754628}" }
        before do
          allow_any_instance_of(Client).to receive(:do_request).and_return(double(:response, status: 201, body: response_body, success?: true))
        end


        it "should return current time of server" do
          response = client.get('/time')

          expect(response.status).to eq(201)
          expect(ActiveSupport::JSON.decode response.body).to eq({'timestamp' => 1466754628 })
        end
      end

      context "/companies" do
        let(:response_body) { "{\"uuid\":\"b5f0f1b0-19e1-0134-2ca0-20c9d0442c1d\",\"name\":\"\xE5\xBD\xA9\xE7\xA8\x8B\xE8\xAE\xBE\xE8\xAE\xA1\",\"full_name\":\"\xE6\x88\x90\xE9\x83\xBD\xE5\xBD\xA9\xE7\xA8\x8B\xE8\xAE\xBE\xE8\xAE\xA1\xE8\xBD\xAF\xE4\xBB\xB6\xE6\x9C\x89\xE9\x99\x90\xE5\x85\xAC\xE5\x8F\xB8\",\"token\":\"a3b6cee5473752965c7e695ecb62429a\",\"logo\":null,\"background\":\"#FFFFFF\",\"color\":\"#7A9E70\"}" }

        before do
          allow_any_instance_of(Client).to receive(:do_request).and_return(double(:response, status: 201, body: response_body, success?: true))
        end

        it "should return the company by token" do
          response = client.get('/company', {  token: token } )
          expect(response.status).to eq(201)
          expect(ActiveSupport::JSON.decode response.body).to eq({"uuid"=>"b5f0f1b0-19e1-0134-2ca0-20c9d0442c1d", "name"=>"彩程设计", "full_name"=>"成都彩程设计软件有限公司", "token"=>"a3b6cee5473752965c7e695ecb62429a", "logo"=>nil, "background"=>"#FFFFFF", "color"=>"#7A9E70"})
        end
      end
    end

    describe "#post" do
      let(:endpoint) { 'http://localhost:3000' }
      let(:access_key) { '83aaa2dc0dc1c4980070ce74b65cca33' }
      let(:secret_key) { 'f161c8796f751111dc267ff8032a6717' }
      let(:token) { 'a3b6cee5473752965c7e695ecb62429a' }
      let(:client) {Client.new(access_key: access_key, secret_key: secret_key, endpoint: endpoint)}

      context "/companies" do
        let(:response_body) { "{\"uuid\":\"1466755961\",\"name\":\"Apple\",\"full_name\":\"Apple Inc.\",\"token\":\"e7dc046a932125962a32797ce7a7174a\",\"logo\":null,\"background\":null,\"color\":null}" }

        before do
          allow_any_instance_of(Client).to receive(:do_request).and_return(double(:response, status: 201, body: response_body, success?: true))
        end

        it "should create the company on server" do
          response = client.post '/companies', { company: { uuid: Time.now.to_i, name: 'Apple', full_name: 'Apple Inc.'}}
          expect(response.status).to eq(201)
          expect(ActiveSupport::JSON.decode response.body).to eq( {"uuid"=>"1466755961", "name"=>"Apple", "full_name"=>"Apple Inc.", "token"=>"e7dc046a932125962a32797ce7a7174a", "logo"=>nil, "background"=>nil, "color"=>nil} )
        end

      end
    end

    describe "#patch" do
      let(:endpoint) { 'http://localhost:3000' }
      let(:access_key) { '83aaa2dc0dc1c4980070ce74b65cca33' }
      let(:secret_key) { 'f161c8796f751111dc267ff8032a6717' }
      let(:token) { 'a3b6cee5473752965c7e695ecb62429a' }
      let(:client) {Client.new(access_key: access_key, secret_key: secret_key, endpoint: endpoint)}

      context "Cancel a appointment" do
        let(:response_body) { "{\"id\":1,\"reason\":\"visit\",\"quantity\":1,\"state\":\"canceled\",\"time\":1466429200,\"arrived_at\":null,\"employee\":{\"uuid\":\"b5f876b0-19e1-0134-2ca1-20c9d0442c1d\",\"name\":\"Terry\",\"phone_number\":\"18602826749\",\"avatar\":null,\"company\":{\"uuid\":\"b5f0f1b0-19e1-0134-2ca0-20c9d0442c1d\",\"name\":\"\xE5\xBD\xA9\xE7\xA8\x8B\xE8\xAE\xBE\xE8\xAE\xA1\",\"full_name\":\"\xE6\x88\x90\xE9\x83\xBD\xE5\xBD\xA9\xE7\xA8\x8B\xE8\xAE\xBE\xE8\xAE\xA1\xE8\xBD\xAF\xE4\xBB\xB6\xE6\x9C\x89\xE9\x99\x90\xE5\x85\xAC\xE5\x8F\xB8\",\"token\":\"a3b6cee5473752965c7e695ecb62429a\",\"logo\":null,\"background\":\"#FFFFFF\",\"color\":\"#7A9E70\"}},\"visitor\":{\"name\":\"\xE8\x91\x9B\xE7\xA2\xA7\xE5\xA9\xB7\",\"phone\":\"18602826751\"}}"}

        before do
          allow_any_instance_of(Client).to receive(:do_request).and_return(double(:response, status: 201, body: response_body, success?: true))
        end


        it "should cancel the appointment and return it " do
          response = client.patch "/appointments/#{1}/cancel", { token: token }

          expect(response.status).to eq(201)
          expect(ActiveSupport::JSON.decode response.body).to eq({"id"=>1, "reason"=>"visit", "quantity"=>1, "state"=>"canceled", "time"=>1466429200, "arrived_at"=>nil, "employee"=>{"uuid"=>"b5f876b0-19e1-0134-2ca1-20c9d0442c1d", "name"=>"Terry", "phone_number"=>"18602826749", "avatar"=>nil, "company"=>{"uuid"=>"b5f0f1b0-19e1-0134-2ca0-20c9d0442c1d", "name"=>"彩程设计", "full_name"=>"成都彩程设计软件有限公司", "token"=>"a3b6cee5473752965c7e695ecb62429a", "logo"=>nil, "background"=>"#FFFFFF", "color"=>"#7A9E70"}}, "visitor"=>{"name"=>"葛碧婷", "phone"=>"18602826751"}})
        end

      end

    end


  end
end

