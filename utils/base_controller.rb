require_relative 'docker_controller'
require_relative '../config/config'

class BaseController


  def test_images
    puts 'Testing images'
    fail = false
    BaseConfig::AVAILABLE_DOCKER_IMAGES.each do |k,v|
      res = docker_controller.test_docker_runnable v
      if res[:stdout] == "Testing #{v}"
        puts res[:stdout] + ' - OK'
      else
        fail = true
      end
    end

    fail
  end

  private

  def docker_controller
    @docker_controller ||= DockerController.new
  end

end