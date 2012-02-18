###########################################################################
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##    http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
###########################################################################

$: << File.expand_path("..", __FILE__) + "/../"

require 'rubygems'
require 'bundler/setup'

require 'test/unit'
require 'vcr'
require 'webmock'

require 'json'
require 'ostruct'
require 'nokogiri'
require 'lib/OneacctClient'

class OneacctClientVCRTest < Test::Unit::TestCase

  def setup

    WebMock.disable_net_connect! :allow => "localhost"

    VCR.config do |c|
      c.cassette_library_dir = 'fixtures/cassettes/oneacct'
      c.stub_with :webmock
    end

    @options = OpenStruct.new

    @options.protocol = :http
    @options.hostname = "localhost"
    @options.port     = 3000
    @options.path     = "/"
    @options.username = "oneadmin"
    @options.password = "onepass"

  end

  def teardown
    ## Nothing really
  end

  def test_oneacct_basic_json

    @options.format = :json

    endpoint = @options.protocol.to_s + "://" + @options.hostname + ":" + @options.port.to_s + @options.path + @options.format.to_s

    client = OneacctClient.new(endpoint, @options.username, @options.password, @options.timeout, @options.debug)

    # use VCR cassette to simulate valid Oneacct JSON communication
    VCR.use_cassette('oneacct_basic_json') do
      assert_nothing_raised {JSON.parse(client.get_all_accounting_data)}
    end

  end

  def test_oneacct_basic_xml

    @options.format = :xml

    endpoint = @options.protocol.to_s + "://" + @options.hostname + ":" + @options.port.to_s + @options.path + @options.format.to_s

    client = OneacctClient.new(endpoint, @options.username, @options.password, @options.timeout, @options.debug)

    # use VCR cassette to simulate valid Oneacct XML communication
    VCR.use_cassette('oneacct_basic_xml') do
      assert_nothing_raised {Nokogiri.parse(client.get_all_accounting_data)}
    end

  end

end