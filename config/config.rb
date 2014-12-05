require 'pathname'
require_relative '../utils/docker_controller'
require_relative '../utils/base_controller'
require_relative '../utils/benchmark_controller'
require_relative '../utils/bench_utils'

class BaseConfig
  AVAILABLE_DOCKER_IMAGES = {
    'ruby-2.1.2' => 'ryccoo/docker-mri-bench:2.1.2',
    # 'ruby-2.1.1' => 'ryccoo/docker-mri-bench:2.1.1',
    # 'ruby-2.0.0' => 'ryccoo/docker-mri-bench:2.0.0',
    # 'ruby-1.9.3' => 'ryccoo/docker-mri-bench:1.9.3',
    # 'ruby-1.9.2' => 'ryccoo/docker-mri-bench:1.9.2',
    # 'jruby-1.7.12' => 'ryccoo/docker-jruby-bench:1.7.12',
    # 'rubinius-2.4.0' => 'ryccoo/docker-rbx-bench:2.4.0'
  }


  DOCKER_CONTROLLER = DockerController.new
  BENCHMARK_CONTROLLER = BenchmarkController.new
  BASE_CONTROLLER = BaseController.new

  def self.path=(p)
    @@path = p
  end

  def self.path
    @@path
  end
end
