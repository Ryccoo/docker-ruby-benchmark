require_relative '../config/config'

class BaseController

  def download_images
    puts 'Downloading images'
    BaseConfig::AVAILABLE_DOCKER_IMAGES.each do |k,gccs|
      gccs.each do |gcc_v, image_name|
        puts 'Downloading image - ' + v
        BaseConfig::DOCKER_CONTROLLER.download_docker_image image_name
      end
    end
  end

  def test_images
    puts 'Testing images'
    success = true
    BaseConfig::AVAILABLE_DOCKER_IMAGES.each do |k,gccs|
      gccs.each do |gcc_v, image_name|
        puts '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '.blue
        puts 'Testing images - ' + image_name

        test_cmd = %{bash -c "gcc -v && ruby -e 'puts RUBY_DESCRIPTION, RbConfig::CONFIG[%{cflags}]'"}
        res = BaseConfig::DOCKER_CONTROLLER.test_docker_runnable image_name, test_cmd

        # check gcc version
        if res[:stderr].lines.last =~ /gcc version #{gcc_v.split(' ')[1]}/
          puts "Check gcc version: '#{gcc_v.split(' ')[1]}' - OK".green
        else
          puts 'Error checking gcc version'.red
          success = false
        end

        # check ruby version
        if res[:stdout].lines.first =~ / #{k.split('-')[1]}/
          puts "Check ruby version: '#{k.split('-')[1]}' - OK".green
        else
          puts 'Error checking ruby version'.red
          success = false
        end

        # check compilation flags
        if res[:stdout].lines.last =~ / #{gcc_v.split(' ')[2]}/
          puts "Check compilation flags: '#{gcc_v.split(' ')[2]}' - OK".green
        else
          puts 'Error checking compilation flags'.red
          success = false
        end

      end
    end

    puts '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '.blue
    puts "CHECK - #{success}"
    puts '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '.blue
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