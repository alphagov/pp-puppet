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
      critical "Failed to write to the write API" if writing_to_backdrop_fails(backdrop_url, auth, payload)

      sleep(SLEEP_CONST)

      read = read_from_backdrop(backdrop_url, start_time) 

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

      critical "Failed to read latest record from the read API" if (start_time - read_api_timestamp) >= API_TIME_TO_WRITE

      ok "Succeeded in writing and reading from backdrop"
    rescue StandardError => e
      critical "Something went really wrong: #{e.message}"
    end
  end

 private

  def writing_to_backdrop_fails(backdrop_url, bearer_token, payload)
    write = Curl::Easy.http_post(URI.parse(backdrop_url).to_s, payload.to_json) do |curl|
      curl.headers['Content-Type'] = 'application/json'
      curl.headers['Authorization'] = "Bearer #{bearer_token}"
      curl.headers['Content-Type'] = "application/json"
      curl.ssl_verify_peer = false
    end

    return !write.body.to_s.include?("ok")
  end

  def read_from_backdrop(backdrop_url, start_time)
    end_time = start_time + API_TIME_TO_WRITE
    uri_sorting_and_results_limitation = backdrop_url + "?sort_by=_timestamp:descending&limit=1&start_at=#{start_time.iso8601()}&end_at=#{end_time.iso8601()}"

    return Curl::Easy.http_get(uri_sorting_and_results_limitation) do |curlinfo|
      curlinfo.ssl_verify_peer = false
    end
  end
end



