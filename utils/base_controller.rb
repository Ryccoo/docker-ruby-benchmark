require_relative '../config/config'

class BaseController

  def download_images
    puts 'Downloading images'
    success = true
    BaseConfig::AVAILABLE_DOCKER_IMAGES.each do |k,v|
      puts 'Downloading image - ' + v
      res = BaseConfig::DOCKER_CONTROLLER.download_docker_image v
      if res[:stdout] == "Testing #{v}"
        puts res[:stdout] + ' - OK'
      else
        success = false
      end
    end

    success
  end

  def test_images
    puts 'Testing images'
    success = true
    BaseConfig::AVAILABLE_DOCKER_IMAGES.each do |k,v|
      puts 'Testing images - ' + v
      res = BaseConfig::DOCKER_CONTROLLER.test_docker_runnable v
      if res[:stdout] == "Testing #{v}"
        puts res[:stdout] + ' - OK'
      else
        success = false
      end
    end

    success
  end

  def remove_containers
    puts 'Removing containers'

    containers = BenchUtils.run_command 'docker ps -a | grep ryccoo | cut -f 1 -d " "'
    count = containers[:stdout].split("\n").count
    containers = containers[:stdout].gsub("\n", ' ')

    if count > 0
      BenchUtils.spawn_command "docker rm #{containers}"
    else
      puts 'No containers found'
      return true
    end
  end

end