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

$: << File.dirname(__FILE__) + '/common'

require 'CloudClient'

class OneacctClient

  ######################################################################
  # Initialize client library
  ######################################################################
  def initialize(endpoint_str=nil, user=nil, pass=nil,
      timeout=nil, debug_flag=true)

    @debug   = debug_flag
    @timeout = timeout

    # Server location
    if endpoint_str
      @endpoint =  endpoint_str
    elsif ENV["ONEACCT_URL"]
      @endpoint = ENV["ONEACCT_URL"]
    else
      @endpoint = "http://localhost:3000/"
    end

    # Autentication
    if user && pass
      @oneauth = [user, pass]
    else
      @oneauth = CloudClient::get_one_auth
    end

    unless @oneauth
      raise "No authorization data present"
    end

    @oneauth[1] = Digest::SHA1.hexdigest(@oneauth[1])

  end

  def get_specific_accoutning_data(user = nil, from_time = nil, to_time = nil)

    url = URI.parse(@endpoint)

    req = Net::HTTP::Post.new(url.path)

    req.basic_auth @oneauth[0], @oneauth[1]

    res = CloudClient::http_start(url, @timeout) do |http|
      http.request(req)
    end

    if CloudClient::is_error?(res)
      res
    else
      res.body
    end

  end

  def get_all_accounting_data

      url = URI.parse(@endpoint)
      req = Net::HTTP::Get.new(url.path)

      req.basic_auth @oneauth[0], @oneauth[1]

      res = CloudClient::http_start(url, @timeout) {|http|
        http.request(req)
      }

      if CloudClient::is_error?(res)
        res
      else
        res.body
      end

  end

end