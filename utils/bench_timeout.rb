require_relative '../config/config'

class BenchTimeout

  def initialize(time: nil, verbose: nil)
    @verbose = verbose
    @timeout = time || ENV['BENCH_TIMEOUT'] || (5 * 60) # default timeout is 5 min.
    puts "Starting timeout for #{@timeout} seconds!" if (@verbose || ENV['VERBOSE'])
    BaseConfig.timeout_applied = false
    @watcher = Thread.new do
      sleep @timeout
      BaseConfig.timeout_applied = true
      BaseConfig::BASE_CONTROLLER.remove_containers(true)
    end
  end

  def stop
    puts 'Stopping timeout !' if @verbose
    @watcher.kill
  end

end
