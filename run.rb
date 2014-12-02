require 'pry'
require_relative 'utils/bench_utils'
require_relative 'utils/base_controller'
require_relative 'config/config'

base_controller = BaseController.new

base_controller.test_images

# sudo docker run ryccoo/docker-base-rvm:latest echo 'test'