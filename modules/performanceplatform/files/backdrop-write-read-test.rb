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
    start_time = Time.now.utc
    payload = {"_timestamp" => start_time.iso8601()}
    backdrop_url = config[:url]
    auth = config[:auth_token]

    begin

      begin
        write_response = write_to_backdrop(backdrop_url, auth, payload)

        if write_response.response_code != 200
          critical "Received bad status code from write API: #{write_response.response_code}"
        end

        write_response_body = JSON.parse(write_response.body)
        if write_response_body['status'] != 'ok'
          critical "Received invalid response from write API: #{write_response.body}"
        end
      rescue JSON::JSONError, IndexError => e
        critical "Failed to parse JSON from write API: #{e.message}, #{write_response.body}"
      end

      # Allow time for the record to be propagated to mongo cluster
      sleep(SLEEP_CONST)

      read_response = read_from_backdrop(backdrop_url, start_time) 

      begin
        read_response_body = JSON.parse(read_response.body)
        timestamp = read_response_body['data'][0]['_timestamp']
      rescue JSON::JSONError, IndexError => e
        critical "Failed to parse JSON from read API: #{e.message} - #{read.body}"
      end

      begin
        timestamp = Time.parse(timestamp).utc
      rescue TimeError
        critical "Failed to parse time from read API '#{timestamp}'"
      end

      critical "Failed to read latest record from the read API" if (start_time - timestamp) >= API_TIME_TO_WRITE

      ok "Succeeded in writing and reading from backdrop"
    rescue StandardError => e
      critical "Something went really wrong: #{e.message}"
    end
  end

 private

  def write_to_backdrop(backdrop_url, bearer_token, payload)
    Curl::Easy.http_post(URI.parse(backdrop_url).to_s, payload.to_json) do |curl|
      curl.headers['Content-Type'] = 'application/json'
      curl.headers['Authorization'] = "Bearer #{bearer_token}"
      curl.ssl_verify_peer = false
    end
  end

  def read_from_backdrop(backdrop_url, start_time)
    end_time = start_time + API_TIME_TO_WRITE
    uri_sorting_and_results_limitation = backdrop_url + "?sort_by=_timestamp:descending&limit=1&start_at=#{start_time.iso8601()}&end_at=#{end_time.iso8601()}"

    Curl::Easy.http_get(uri_sorting_and_results_limitation) do |curlinfo|
      curlinfo.ssl_verify_peer = false
    end
  end
end



