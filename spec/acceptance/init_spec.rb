# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'webmock/rspec'

describe 'healthcheck' do

  before(:all) do
    WebMock.disable_net_connect!(allow_localhost: true)
    stub_request(:get, "http://example.com")
      .to_return(status: 200, body: "{\"status\":\"ready\"}", headers: {'Content-Type' => 'application/json'})
  end

  it_behaves_like 'an idempotent resource' do
    let(:manifest) do
      <<-PUPPET
      tcp_conn_validator { 'beaker ssh test' :
        host => '127.0.0.1',
        port => 22,
      }
      -> file { '/tmp/hello':
      content => "Hi!\n",
      }
      http_conn_validator { 'mock http test':
        host          => 'example.com',
        port          => '80',
        expected_code => 200,
        verify_peer   => false,
        use_ssl       => false,
        timeout       => 5,
      }
      -> file { '/tmp/foo':
        content => "Hi!\n",
      }
      PUPPET
    end
  end
  describe file('/tmp/hello') do
    it { is_expected.to be_file }
  end

  describe file('/tmp/foo') do
    it { is_expected.to be_file }
  end
end
