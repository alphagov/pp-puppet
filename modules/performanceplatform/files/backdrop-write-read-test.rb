require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'json'
require 'curb'
require 'time'
require 'sensu-plugin/check/cli'

#if the read test fails we may need to increase the sleep time
SLEEP_CONST = 0.8
API_TIME_TO_WRITE = 121
class BackdropWriteReadTest< Sensu::Plugin::Check::CLI

  option :url,
         :description => 'URL address',
         :short => '-u URL',
         :long => '--url URL',
         :required => true
  option :auth_token,
         :description => 'Bearer Token',
         :short => '-b BEARER',
         :long => '--bearer BEARER',
         :required => true
  def run
  payload = {"_timestamp" =>Time.now.utc.iso8601()}
  uri = URI.parse(config[:url])
  auth = config[:auth_token]
  content_type = "application/json"
  begin
    write = Curl::Easy.http_post(uri.to_s, payload.to_json) do |curl|
      curl.headers['Content-Type'] = 'application/json'
      curl.headers['Authorization'] = "Bearer #{auth}"
      curl.headers['Content-Type'] = content_type
      curl.ssl_verify_peer = false
    end
    if  write.body.to_s.include? "ok"
      sleep(SLEEP_CONST)

      uri_sorting_and_results_limitation = config[:url] + "?sort_by=_timestamp:descending&limit=1"
      read = Curl::Easy.http_get(uri_sorting_and_results_limitation) do |curlinfo|
        curlinfo.ssl_verify_peer = false
      end

      begin
        read_api_response = JSON.parse(read.body)
        read_api_timestamp = read_api_response['data'][0]['_timestamp']
      rescue JSONError, IndexError
        critical "Failed to parse JSON from read API"
      end
      begin
        read_api_timestamp = Time.parse(read_api_timestamp).utc
      rescue TimeError
        critical "Failed to parse time from read API '#{read_api_timestamp}'"
      end
      begin
        utc_time = Time.parse(payload["_timestamp"]).utc
      rescue TimeError
        critical "Failed to parse time from local payload '#{payload['_timestamp']}'"
      end
      if (utc_time - read_api_time_stamp) < API_TIME_TO_WRITE
        ok "Succeeded in writing and reading from backdrop"
      else
        critical "Failed to read latest record from the read API"
      end

    else
      critical "Failed to write to the write API";
    end

    end
  rescue
    critical "Something went really wrong"
  end
end



