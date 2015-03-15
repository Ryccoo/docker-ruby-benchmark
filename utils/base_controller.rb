require_relative '../config/config'

class BaseController

  def download_images
    puts 'Downloading images'
    BaseConfig::AVAILABLE_DOCKER_IMAGES.each do |k,gccs|
      gccs.each do |gcc_v, image_name|
        puts 'Downloading image - ' + image_name
        BaseConfig::DOCKER_CONTROLLER.download_docker_image image_name
      end
    end
  end

  def test_images
    puts 'Testing images'
    success = true
    BaseConfig::AVAILABLE_DOCKER_IMAGES.each do |k,gccs|
      gccs.each do |gcc_v, image_name|
        puts BaseConfig::SEPARATOR.blue
        puts 'Testing images - ' + image_name

        test_cmd = %{bash -lc "clang -v; gcc -v; ruby -v && ruby -rrbconfig -e 'puts RbConfig::CONFIG[%{CFLAGS}]; puts RbConfig::CONFIG[%{CC}]'"}
        res = BaseConfig::DOCKER_CONTROLLER.test_docker_runnable image_name, test_cmd

        # check gcc version
        if gcc_v =~ /\AGCC/
          if res[:stderr].lines.last =~ /gcc version #{gcc_v.split(' ')[1]}/
            puts "Check gcc version: '#{gcc_v.split(' ')[1]}' - OK".green
          else
            puts 'Error checking gcc version'.red
            success = false
          end
        elsif gcc_v =~ /\AClang/
          if res[:stderr].lines.first(5).join =~ /clang version #{gcc_v.split(' ')[1]}/
            puts "Check clang version: '#{gcc_v.split(' ')[1]}' - OK".green
          else
            puts 'Error checking clang version'.red
            success = false
          end
        end

        # check ruby version
        if res[:stdout].lines.first =~ / #{k.split('-')[1]}/
          puts "Check ruby version: '#{k.split('-')[1]}' - OK".green
        else
          puts 'Error checking ruby version'.red
          success = false
        end

        if k =~ /\Aruby/
          # check compilation flags
          if res[:stdout].lines[-2] =~ /#{gcc_v.split(' ')[2]}/
            puts "Check compilation flags: '#{gcc_v.split(' ')[2]}' - OK".green
          else
            puts 'Error checking compilation flags'.red
            success = false
          end
          # check cc used in compilation
          if res[:stdout].lines[-1].downcase == gcc_v.split(' ')[0].downcase
            puts "Check compiler used: '#{gcc_v.split(' ')[0]}' - OK".green
          else
            puts 'Error checking compiler'.red
            success = false
          end
        end

        STDOUT.flush
      end
    end

    puts BaseConfig::SEPARATOR.blue
    puts "CHECK - #{success}"
    puts BaseConfig::SEPARATOR.blue
    success
  end

  def remove_containers(running = false)
    puts BaseConfig::SEPARATOR.blue
    puts 'Removing containers'

    if running
      containers = BenchUtils.run_command 'docker ps | grep ryccoo | cut -f 1 -d " "'
    else
      containers = BenchUtils.run_command 'docker ps -a | grep ryccoo | cut -f 1 -d " "'
    end
    count = containers[:stdout].split("\n").count
    containers = containers[:stdout].gsub("\n", ' ')

    if count > 0
      if running
        BenchUtils.spawn_command "docker rm  -f #{containers}"
      else
        BenchUtils.spawn_command "docker rm #{containers}"
      end
    else
      puts 'No containers found'
      return true
    end
  end

end