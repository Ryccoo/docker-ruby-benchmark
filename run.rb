require 'pry'
require_relative 'config/config'
require 'pathname'

PATH = Pathname.new(File.expand_path('..', __FILE__))
BaseConfig.path = PATH

if ARGV.delete('pull')
  unless BaseConfig::BASE_CONTROLLER.download_images
    puts 'Error downloading images'
    exit(1)
  end
  exit(0)
end

if ARGV.delete('clear')
  unless BaseConfig::BASE_CONTROLLER.remove_containers
    puts 'Error removing containers'
    exit(1)
  end
  exit(0)
end

if ARGV.delete('publish')
  publisher = BenchPublisher.new
  if publisher.enabled?
    publisher.publish_all
  end
  exit(0)
end

if ARGV.delete('test')
  unless BaseConfig::BASE_CONTROLLER.test_images
    puts 'Error testing images'
    exit(1)
  end
  exit(0)
end

unless BaseConfig::BASE_CONTROLLER.test_images
  puts 'Error testing images'
end


BaseConfig::BENCHMARK_CONTROLLER.run_benchmarks(repeats: ENV['BENCH_REPEATS'])