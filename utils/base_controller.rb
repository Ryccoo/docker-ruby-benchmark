require_relative 'docker_controller'
require_relative '../config/config'

class BaseController


  def test_images
    puts 'Testing images'
    success = true
    BaseConfig::AVAILABLE_DOCKER_IMAGES.each do |k,v|
      puts 'Downloading image - ' + v
      res = docker_controller.test_docker_runnable v
      if res[:stdout] == "Testing #{v}"
        puts res[:stdout] + ' - OK'
      else
        success = false
      end
    end

    success
  end

  def run_benchmark_game
    puts 'Running benchmark game'
    BaseConfig::AVAILABLE_DOCKER_IMAGES.each do |k,v|
      docker_controller.run_benchmark_game(k, v)
    end
  end

  private

  def docker_controller
    @docker_controller ||= DockerController.new
  end

end