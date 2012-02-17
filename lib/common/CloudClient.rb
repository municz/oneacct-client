# -------------------------------------------------------------------------- #
# Copyright 2002-2011, OpenNebula Project Leads (OpenNebula.org)             #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

require 'rubygems'
require 'uri'

require 'digest/sha1'
require 'net/https'

require "rexml/document"

begin
    require 'rexml/formatters/pretty'
    REXML_FORMATTERS=true
rescue LoadError
    REXML_FORMATTERS=false
end

begin
    require 'curb'
    CURL_LOADED=true
rescue LoadError
    CURL_LOADED=false
end

begin
    require 'net/http/post/multipart'
    MULTIPART_LOADED=true
rescue LoadError
    MULTIPART_LOADED=false
end

###############################################################################
# The CloudClient module contains general functionality to implement a
# Cloud Client
###############################################################################
module CloudClient
    # #########################################################################
    # Default location for the authentication file
    # #########################################################################
    DEFAULT_AUTH_FILE = ENV["HOME"]+"/.one/one_auth"

    # #########################################################################
    # Gets authorization credentials from ONE_AUTH or default
    # auth file.
    #
    # Raises an error if authorization is not found
    # #########################################################################
    def self.get_one_auth
        if ENV["ONE_AUTH"] and !ENV["ONE_AUTH"].empty? and
           File.file?(ENV["ONE_AUTH"])
            one_auth=File.read(ENV["ONE_AUTH"]).strip.split(':')
        elsif File.file?(DEFAULT_AUTH_FILE)
            one_auth=File.read(DEFAULT_AUTH_FILE).strip.split(':')
        else
            raise "No authorization data present"
        end

        raise "Authorization data malformed" if one_auth.length < 2

        one_auth
    end

    # #########################################################################
    # Starts an http connection and calls the block provided. SSL flag
    # is set if needed.
    # #########################################################################
    def self.http_start(url, timeout, &block)
        http = Net::HTTP.new(url.host, url.port)

        if timeout
            http.read_timeout = timeout.to_i
        end

        if url.scheme=='https'
            http.use_ssl = true
            http.verify_mode=OpenSSL::SSL::VERIFY_NONE
        end

        begin
            http.start do |connection|
                block.call(connection)
            end
        rescue Errno::ECONNREFUSED => e
            str =  "Error connecting to server (#{e.to_s}).\n"
            str << "Server: #{url.host}:#{url.port}"

            return CloudClient::Error.new(str)
        rescue Errno::ETIMEDOUT => e
            str =  "Error timeout connecting to server (#{e.to_s}).\n"
            str << "Server: #{url.host}:#{url.port}"

            return CloudClient::Error.new(str)
        rescue Timeout::Error => e
            str =  "Error timeout while connected to server (#{e.to_s}).\n"
            str << "Server: #{url.host}:#{url.port}"

            return CloudClient::Error.new(str)
        end
    end

    # #########################################################################
    # The Error Class represents a generic error in the Cloud Client
    # library. It contains a readable representation of the error.
    # #########################################################################
    class Error
        attr_reader :message

        # +message+ a description of the error
        def initialize(message=nil)
            @message=message
        end

        def to_s()
            @message
        end
    end

    # #########################################################################
    # Returns true if the object returned by a method of the OpenNebula
    # library is an Error
    # #########################################################################
    def self.is_error?(value)
        value.class==CloudClient::Error
    end
end

# Command line help functions
module CloudCLI
    def print_xml(xml_text)
        begin
            doc = REXML::Document.new(xml_text)
        rescue REXML::ParseException => e
            return e.message, -1 
        end

        xml = doc.root

        if xml.nil?
            return xml_text, -1
        end

        str = String.new
        if REXML_FORMATTERS
            formatter = REXML::Formatters::Pretty.new
            formatter.compact = true

            formatter.write(xml,str)
        else
            str = xml.to_s
        end
        
        return str, 0
    end
    
    # Returns the command name
    def cmd_name
        File.basename($0)
    end
    
    def version_text
        version=<<EOT
OpenNebula 3.0.0
Copyright 2002-2011, OpenNebula Project Leads (OpenNebula.org)

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
EOT
    end
end
