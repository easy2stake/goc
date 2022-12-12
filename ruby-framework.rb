require 'json'
require 'fileutils'
require 'env'
require 'faraday'
require 'thread'
require 'thwait'
require 'logger'
require 'date'

# Setting the logging here
def setup_logger()
    $log = Logger.new(STDOUT)
    $log.level = Logger::INFO
    $log.formatter = proc { |severity, datetime, progname, msg| "#{severity} #{datetime} #{msg}\n" }
end

setup_logger()

def backup_file(file)
    if File.file?(file)
      time = Time.now
      date = time.strftime('%Y%m%d%H%M%S')
      FileUtils.cp(file, "./bkp/#{file}.#{date}.bkp")
    end
end

def http_post (url, body)
  httpMaxRetries = 10
  # puts "http_post - Request URL #{url}"
  # puts "http_post - Request BODY #{body}"
  begin
    retries ||= 0
    conn = Faraday.new do |conn|
      conn.options.timeout = 30
    end
    resp = conn.post(url, body, {"Content-Type"=>"application/json"})
    return JSON.parse(resp.body)
  rescue
    $log.warn "Retry ##{retries}. Cannot query RPC: #{url}"
    if (retries += 1) < httpMaxRetries
      sleep 1
      retry
    end
    $log.error "ERROR_1 - Retry attempts exceeded. Cannot query RPC: #{url}"
    $log.error "ERROR_2 - Response body: #{resp.body}"
    exit 1
  end
end

def http_get (url)
  httpMaxRetries = 5
  begin
    retries ||= 0
    conn = Faraday.new(:url => url,  :ssl => {:verify => false})
    resp = conn.get
    return resp.body

  rescue
    $log.warn "http_get -> Retry ##{retries}. Cannot query RPC: #{url}"
    if (retries += 1) < httpMaxRetries
      sleep 1
      retry
    end
    $log.error "http_get -> ERROR_1 - Retry attempts exceeded. Cannot query RPC: #{url}"
    #$log.error "ERROR_2 - HTTP STATUS: #{resp.status}"
    #$log.error "ERROR_2 - Response body: #{resp.body}"
    return 1
  end
end

def json_file_to_hash(jsonfile)
    begin
        file = File.read(jsonfile)
        data_hash =  JSON.parse(file)
        return data_hash
        # Something to use in the future
        #my_hash.transform_keys(&:to_sym)
    rescue => error
        $log.error error
        $log.error "json_file_to_hash -> ERROR: Something went wrong when reading file: #{jsonfile}"
        $log.error "json_file_to_hash -> ERROR: Returning an EMPTY HASH !"
        return {}
    end
end

# ATTENTION: It will overwrite any existing file. It will backup first though!
def hash_to_json_file(hash, file)
    backup_file(file)
    File.open(file,"w") do |f|
      f.puts JSON.pretty_generate(hash)
    end
end

# ATTENTION: It will overwrite any existing file. It will backup first though!
def write_to_file(string, file)
    backup_file(file)
    File.open(file,"w") do |f|
      f.puts (string)
    end
end

# To merge 2 hashes - never tested
def merge_recursively(a, b)
  a.merge(b) {|key, a_item, b_item| merge_recursively(a_item, b_item) }
end

def time_diff_seconds(time1, time2)
  # Example usage
  # diff_seconds = time_diff_seconds("2022-12-01T17:00:08.554937899Z", "2022-12-01T17:00:20.13016482Z")
  # puts diff_seconds  # prints 11.575228321

  # Parse the timestamps
  time1 = DateTime.parse(time1)
  time2 = DateTime.parse(time2)

  # Calculate the difference in seconds
  diff_seconds = (time2 - time1) * 24 * 60 * 60

  return diff_seconds
end




# Ruby lambda function example
# func = lambda do
#     x=x+1
# end
# func.call()
# func.call()
# puts x # => 2
