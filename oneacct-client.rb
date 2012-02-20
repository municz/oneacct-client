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

      if options.for_user.nil? && options.to_time.nil? && options.from_time.nil?
        json_data = JSON.parse client.get_all_accounting_data
      else
        json_data = JSON.parse client.get_specific_accoutning_data options.for_user, options.from_time, options.to_time
      end

      puts JSON.pretty_generate json_data

    when :xml

      if options.for_user.nil? && options.to_time.nil? && options.from_time.nil?
        xml_data = Nokogiri.XML(client.get_all_accounting_data) do |config|
          config.default_xml.noblanks
        end
      else
        xml_data = Nokogiri.XML(client.get_specific_accoutning_data options.for_user, options.from_time, options.to_time) do |config|
          config.default_xml.noblanks
        end
      end

      puts xml_data.to_xml(:indent => 2)

    else
      raise "Unknown format!"
  end

rescue Exception => e
  puts "Failed to get a valid response from the server. " + e.message
  exit 1
end