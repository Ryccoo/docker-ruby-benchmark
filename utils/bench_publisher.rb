require 'time'
require_relative '../config/config'
require 'net/http'
require 'uri'

class BenchPublisher
  PAGE = "/api/v1/results"

  def initialize
    @site = ENV['BENCH_SITE']
    @key = ENV['BENCH_SECRET']
    @port = ENV['BENCH_SITE_PORT']

    if @site && @key
      @uri = URI.parse(@site)
    end

    @published_lines = 0
    @total_lines = 0

    total_count
  end

  def enabled?
    !!(@site && @key)
  end

  def publish_all
    BaseConfig::AVAILABLE_DOCKER_IMAGES.keys.each do |k|
      publish_file k
    end
  end

  def publish_file(version)
    lines = file_lines(version)
    lines.each do |line|
      publish_line line
    end
  end

  def publish_line(line)
    data = line.split(';')

    benchmark = data[0].match(/.*\.rb/)[0]
    version = data[1]
    gcc_version = data[2]
    name = data[3]
    time = data[4]
    run_at = Time.parse(data[5])
    memory = data[6]
    total_memory = data[7]

    unless time == 'FAILED' || time == 'TIMEOUT'
      http = Net::HTTP.new(@uri.host, @port || @uri.port)
      request = Net::HTTP::Post.new(PAGE)
      request.set_form_data({
                              secret_token: @key,
                              gcc_version: gcc_version,
                              executable: benchmark,
                              name: name,
                              ruby: version,
                              time: time,
                              run_at: run_at,
                              memory: memory,
                              total_memory: total_memory
                            })
      response = http.request(request)
      @published_lines += 1
      puts "#{@published_lines} / #{@total_lines}: #{response.body}"
    end
  end

  def file_lines(version)
    data = File.read(BaseConfig.path.join('results', "#{version}.csv")).lines

    return data
  rescue
    return []
  end

  def total_count
    BaseConfig::AVAILABLE_DOCKER_IMAGES.keys.each do |k|
      lines = file_lines(k)
      @total_lines += lines.count
    end
  end

end