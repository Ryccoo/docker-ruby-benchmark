require 'pathname'
require 'dotenv'
require_relative '../utils/docker_controller'
require_relative '../utils/base_controller'
require_relative '../utils/benchmark_controller'
require_relative '../utils/bench_utils'
require_relative '../utils/formatter'
require_relative '../utils/bench_publisher'
require_relative '../utils/bench_timeout'

# load .env file
Dotenv.load

class BaseConfig
  AVAILABLE_DOCKER_IMAGES = {
    'ruby-2.2.0' => {
      'GCC 4.8 -O2' => 'ryccoo/mri-gcc-4.8-o2:2.2.0',
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:2.2.0',
      'GCC 4.9 -O2' => 'ryccoo/mri-gcc-4.9-o2:2.2.0',
      'GCC 4.9 -O3' => 'ryccoo/mri-gcc-4.9-o3:2.2.0',
      'Clang 3.3 -O2' => 'ryccoo/mri-clang-3.3-o2:2.2.0',
      'Clang 3.3 -O3' => 'ryccoo/mri-clang-3.3-o3:2.2.0',
      'Clang 3.4 -O2' => 'ryccoo/mri-clang-3.4-o2:2.2.0',
      'Clang 3.4 -O3' => 'ryccoo/mri-clang-3.4-o3:2.2.0',
      'Clang 3.5 -O2' => 'ryccoo/mri-clang-3.5-o2:2.2.0',
      'Clang 3.5 -O3' => 'ryccoo/mri-clang-3.5-o3:2.2.0',
    },
    'ruby-2.1.5' => {
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:2.1.5',
    },
    'ruby-2.1.4' => {
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:2.1.4',
    },
    'ruby-2.1.3' => {
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:2.1.3',
    },
    'ruby-2.1.2' => {
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:2.1.2',
    },
    'ruby-2.1.1' => {
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:2.1.1',
    },
    'ruby-2.1.0' => {
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:2.1.0',
    },
    'ruby-2.0.0' => {
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:2.0.0',
    },
    'ruby-1.9.3' => {
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:1.9.3',
    },
    'ruby-1.9.2' => {
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:1.9.2',
    },
    'ruby-1.9.1' => {
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:1.9.1',
    },
    'ruby-1.8.7' => {
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:1.8.7',
    },
    'ruby-1.8.6' => {
      'GCC 4.8 -O2' => 'ryccoo/mri-gcc-4.8-o3:1.8.6', # lets make exception, this version can not compile with O3
    },
    'jruby-9.0.0.0.pre1' => {
      'Undefined' => 'ryccoo/jruby:9.0.0.0.pre1'
    },
    'jruby-1.7.12' => {
      'Undefined' => 'ryccoo/jruby:1.7.12'
    },
    'jruby-1.6.8' => {
      'Undefined' => 'ryccoo/jruby:1.6.8'
    },
#    'rubinius-2.5.2' => {
#      'Undefined' => 'ryccoo/rubinius:2.5.2'
#    },
    'rubinius-2.4.1' => {
      'Undefined' => 'ryccoo/rubinius:2.4.1'
    },
    'rubinius-2.4.0' => {
      'Undefined' => 'ryccoo/rubinius:2.4.0'
    },
    'rubinius-2.3.0' => {
      'Undefined' => 'ryccoo/rubinius:2.3.0'
    },
    'rubinius-2.2.10' => {
      'Undefined' => 'ryccoo/rubinius:2.2.10'
    },
  }


  DOCKER_CONTROLLER = DockerController.new
  BENCHMARK_CONTROLLER = BenchmarkController.new
  BASE_CONTROLLER = BaseController.new

  REPETITIONS = 10

  SEPARATOR = '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '



  def self.path=(p)
    @@path = p
  end

  def self.path
    @@path
  end

  def self.timeout_applied=(val)
    @@timeout_applied = val
  end

  def self.timeout_applied
    @@timeout_applied
  end
end
