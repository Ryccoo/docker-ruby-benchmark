require 'pry'
require_relative 'utils/bench_utils'
require_relative 'utils/base_controller'
require_relative 'config/config'
require 'pathname'

PATH = Pathname.new(File.expand_path('..', __FILE__))

base_controller = BaseController.new

unless base_controller.test_images
  puts 'Error testing images'
  exit(1)
end

base_controller.run_benchmark_game