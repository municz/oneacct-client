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

require 'ostruct'

class OptparseOneacctClient

  VERSION = 0.99

  def self.parse(args)

    options = OpenStruct.new

    options.debug = false

    options.hostname = "localhost"
    options.port = 3000
    options.path = "/"
    options.protocol = :http
    options.username = "oneadmin"
    options.password = "onepass"

    options.format = :json

    options.timeout = 60

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: oneacct-client.rb [options]"

      opts.separator ""
      opts.separator "Connection options:"

      opts.on("--protocol [http|https]", [:http, :https], "Protocol to use, defaults to 'http'") do |protocol|
        options.protocol = protocol
      end

      opts.on("--hostname [HOSTNAME]", String, "Host to be queried, defaults to 'localhost'") do |hostname|
        options.hostname = hostname
      end

      opts.on("--port [PORT_NUMBER]", Integer, "Port to be queried, defaults to '2633'") do |port|
        options.port = port
      end

      opts.on("--path [PATH]", String, "Path to the service endpoint (the last part of the URI, should always start with a slash), defaults to '/'") do |path|
        options.path = path
      end

      opts.on("--username [USERNAME]", String, "Username for authentication purposes, defaults to 'oneadmin'") do |username|
        options.username = username
      end

      opts.on("--password [PASSWORD]", String, "Password for authentication purposes, defaults to 'onepass'") do |password|
        options.password = password
      end

      opts.separator ""
      opts.separator "Service options:"

      opts.on("--format [SECONDS]", [:json, :xml], "Format of the response [json|xml]") do |format|
        options.format = format
      end

      opts.on("-u", "--for-user [USER_ID]", Integer, "Get accounting data for a specific user") do |for_user|
        options.for_user = for_user
      end

      opts.on("-f", "--from-time [UNIX_TIME]", Integer, "Get accounting data from specified time on") do |from_time|
        options.from_time = from_time
      end

      opts.on("-t", "--to-time [UNIX_TIME]", Integer, "Get accounting data up until this time") do |to_time|
        options.to_time = to_time
      end

      opts.separator ""
      opts.separator "Session options:"

      opts.on("--timeout [SECONDS]", Integer, "Timeout time in seconds, defaults to '60'") do |timeout|
        options.timeout = timeout
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on("--[no-]debug", "Run with debugging options, defaults to 'no-debug'") do |debug|
        options.debug = debug
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit!
      end

      opts.on_tail("--version", "Show version") do
        puts VERSION
        exit!
      end

    end

    opts.parse!(args)

    mandatory = [:protocol, :hostname, :port, :path, :username, :password, :format]
    options_hash = options.marshal_dump

    missing = mandatory.select{ |param| options_hash[param].nil? }
    if not missing.empty?
      raise Exception.new("Missing required arguments #{missing.join(', ')}")
    end

    options

  end

end