require 'pathname'
require 'dotenv'
require_relative '../utils/docker_controller'
require_relative '../utils/base_controller'
require_relative '../utils/benchmark_controller'
require_relative '../utils/bench_utils'
require_relative '../utils/formatter'
require_relative '../utils/bench_publisher'

# load .env file
Dotenv.load

class BaseConfig
  AVAILABLE_DOCKER_IMAGES = {
    'ruby-2.1.5' => {
      'GCC 4.9 -O2' => 'ryccoo/mri-gcc-4.9-o2:2.1.5',
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:2.1.5',
    },
    'ruby-2.1.4' => {
      'GCC 4.9 -O2' => 'ryccoo/mri-gcc-4.9-o2:2.1.4',
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:2.1.4',
    },
    'ruby-2.1.3' => {
      'GCC 4.9 -O2' => 'ryccoo/mri-gcc-4.9-o2:2.1.3',
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:2.1.3',
    },
    'ruby-2.1.2' => {
      'GCC 4.9 -O2' => 'ryccoo/mri-gcc-4.9-o2:2.1.2',
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:2.1.2',
    },
    'ruby-2.1.1' => {
      'GCC 4.9 -O2' => 'ryccoo/mri-gcc-4.9-o2:2.1.1',
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:2.1.1',
    },
    'ruby-2.1.0' => {
      'GCC 4.9 -O2' => 'ryccoo/mri-gcc-4.9-o2:2.1.0',
      'GCC 4.8 -O3' => 'ryccoo/mri-gcc-4.8-o3:2.1.0',
    },
    # 'ruby-2.1.4' => 'ryccoo/docker-mri-bench:2.1.4',
    # 'ruby-2.1.2' => 'ryccoo/docker-mri-bench:2.1.2',
    # 'ruby-2.1.1' => 'ryccoo/docker-mri-bench:2.1.1',
    # 'ruby-2.0.0' => 'ryccoo/docker-mri-bench:2.0.0',
    # 'ruby-1.9.3' => 'ryccoo/docker-mri-bench:1.9.3',
    # 'ruby-1.9.2' => 'ryccoo/docker-mri-bench:1.9.2',
    # 'ruby-1.9.1' => 'ryccoo/docker-mri-bench:1.9.1',
    # 'ruby-1.8.7' => 'ryccoo/docker-mri-bench:1.8.7',
    # 'ruby-1.8.6' => 'ryccoo/docker-mri-bench:1.8.6',
    # 'jruby-1.7.12' => 'ryccoo/docker-jruby-bench:1.7.12',
    # 'jruby-1.6.8' => 'ryccoo/docker-jruby-bench:1.6.8',
    # 'rubinius-2.4.1' => 'ryccoo/docker-rbx-bench:2.4.1',
    # 'rubinius-2.4.0' => 'ryccoo/docker-rbx-bench:2.4.0',
    # 'rubinius-2.3.0' => 'ryccoo/docker-rbx-bench:2.3.0',
    # 'rubinius-2.2.10' => 'ryccoo/docker-rbx-bench:2.2.10'
  #   # Not working now
  #   # 'rubinius-2.2.2' => 'ryccoo/docker-rbx-bench:2.2.2',
  #   # 'rubinius-2.1.0' => 'ryccoo/docker-rbx-bench:2.1.0',
  #   # 'rubinius-2.0.0' => 'ryccoo/docker-rbx-bench:2.0.0',
  }


  DOCKER_CONTROLLER = DockerController.new
  BENCHMARK_CONTROLLER = BenchmarkController.new
  BASE_CONTROLLER = BaseController.new

  REPETITIONS = 10



  def self.path=(p)
    @@path = p
  end

  def self.path
    @@path
  end
end
