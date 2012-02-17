#!/usr/bin/env ruby
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

$: << File.dirname(__FILE__)

#
require 'rubygems'
require 'bundler/setup'

require 'json'
require 'pp'
require 'optparse'
require 'nokogiri'

require 'lib/OneacctClient'
require 'lib/OptparseOneacctClient'

# test
begin

  options = OptparseOneacctClient.parse(ARGV)

  endpoint = options.protocol.to_s + "://" + options.hostname + ":" + options.port.to_s + options.path + options.format.to_s

  client = OneacctClient.new(endpoint, options.username, options.password, options.timeout, options.debug)

  case options.format
    when :json

      json_data = JSON.parse client.get_all_accounting_data
      puts JSON.pretty_generate json_data

    when :xml

      xml_data = Nokogiri.XML(client.get_all_accounting_data) do |config|
        config.default_xml.noblanks
      end

      puts xml_data.to_xml(:indent => 2)

    else
      raise Exception.new "Unknown format!"
  end

rescue Exception => e
  puts "Failed to get a valid response from the server."
  exit 1
end