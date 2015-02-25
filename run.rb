#!/usr/bin/env ruby

require 'pry'
require_relative 'config/config'
require 'pathname'

PATH = Pathname.new(File.expand_path('..', __FILE__))
BaseConfig.path = PATH

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

require 'optparse'


# namiesto options pouzivat commands bez pomlciek, popripade premenovat na neco ine ako run.rb
class Parser
  def self.parse(arguments)
    options = {}

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: run.rb [options]"

      opts.on("-d", "--pull", "Pull all docker images") do |n|
        options[:pull] = n
      end

      opts.on("-t", "--test", "Test docker images") do |n|
        options[:test] = n
      end

      opts.on("-c", "--clear", "Clear all unused docker containers") do |n|
        options[:clear] = n
      end

      opts.on("-p", "--publish", "Publish all collected results") do |n|
        options[:publish] = n
      end

      opts.on("-r", "--run", "Run benchmarks") do |n|
        options[:run] = n
        opts.separator("")
        opts.separator("common options:")
      end

      opts.on("-h", "--help", "Prints this help") do
        puts opts
        puts BaseConfig::SEPARATOR
        explanation = <<-EOE
\033[1mENVIRONMENT SETTINGS\033[0m
  This benchmark suite uses ENV gem that allows you to store all your environment settings into file.
  This file is located in root of this application (where the file run.rb is located) and needs to be named "\033[1m.env\033[0m".

  \033[1mEnvironment settings for benchmarking\033[0m

    BENCH_REPEATS=x                  Repeat each benchmark x times. Default value is 10.

    BENCH_FILE=name                  Runs only selected benchmark. Use full path from benchmarks folder.
                                      Example: \033[1mBENCH_FILE="ruby-official/bm_vm3_gc.rb" ./run.rb --run\033[0m will
                                      run benchmark suite only for benchmark bm_vm3_gc.rb located in benchmarks/ruby-official
                                      folder.

    BENCH_SKIP_STARTUP_TEST=true     Skip docker images test on suite start. Default value is false.

    VERBOSE=true                     Verbose mode. Default is false.

  \033[1mRubyFy.Me options for publishing to rails app\033[0m
    BENCH_SECRET=String              Secret token used to authorize results on publishing. Same value key and value need
                                     to be set at RubyFy.Me rails app.

    BENCH_SITE=site                  URL (WITHOUT PORT) of rails app displaying stored results.
                                      Examples: \033[1mBENCH_SITE="localhost" BENCH_PORT=3000 ./run.rb --publish\033[0m
                                                \033[1mBENCH_SITE="http://rubyfy.me" ./run.rb --publish\033[0m

    BENCH_PORT=x                    Port of rails app displaying stored results.
                                      Example: \033[1mBENCH_SITE=localhost BENCH_PORT=3000 ./run.rb --publish\033[0m will
                                      push results to localhost on port 3000.
                                      IMPORTANT: USE THIS ONLY WHEN PORT IS DIFFERENT THAN 80
        EOE
        puts explanation
        exit
      end
    end

    opt_parser.parse!(arguments)
    return options
  end
end

options = Parser.parse(ARGV)

if options.keys.count != 1
  puts "Invalid number of arguments, please use only one at the time.\nUse -h or --help to display help"
  exit
end

if options[:pull]
  unless BaseConfig::BASE_CONTROLLER.download_images
    puts 'Error downloading images'
    exit(1)
  end
  exit(0)
end

if options[:clear]
  unless BaseConfig::BASE_CONTROLLER.remove_containers
    puts 'Error removing containers'
    exit(1)
  end
  exit(0)
end

if options[:publish]
  publisher = BenchPublisher.new
  if publisher.enabled?
    publisher.publish_all
  else
    $stderr.puts "Publishing is not available, make sure BENCH_SECRET and \
BENCH_SITE environment veriable are correctly set. Use --help to display help."
    exit(1)
  end
  exit(0)
end

if options[:test]
  unless BaseConfig::BASE_CONTROLLER.test_images
    puts 'Error testing images'
    exit(1)
  end
  exit(0)
end

if options[:run]
  unless ENV['BENCH_SKIP_STARTUP_TEST']
    unless BaseConfig::BASE_CONTROLLER.test_images
      puts 'Error testing images'
      exit 1
    end
  end

  BaseConfig::BENCHMARK_CONTROLLER.run_benchmarks(repeats: ENV['BENCH_REPEATS'])
end
