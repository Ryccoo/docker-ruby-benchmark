require_relative '../config/config'

class DockerController

  def download_docker_image image_name
    BenchUtils.run_command("docker pull #{image_name}")
  end

  def test_docker_runnable image_name
    BenchUtils.run_command("docker run #{image_name} echo 'Testing #{image_name}'")
  end

  def test_ruby_version ruby_version, image_name
    puts "Testing ruby version: [Should be: #{ruby_version}]".blue
    res = BenchUtils.run_command <<-eos
docker run -i -v ${PWD}/results:/results -v ${PWD}/benchmark-game:/benchmark-game #{image_name} bash -l << COMMANDS
ruby -v
COMMANDS
    eos

    res
  end

  def run_benchmark_game image_name, game_with_args
    puts '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '.blue
    puts "RUNNING BENCHMARK '#{game_with_args}'".green
    puts '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '.blue
    res = BenchUtils.run_command <<-eos
docker run -i -v ${PWD}/results:/results -v ${PWD}/benchmark-game:/benchmark-game #{image_name} bash -l << COMMANDS
cd /benchmark-game/benchmarks && \
bash -lc 'time -p ruby #{game_with_args}' >/tmp/stdout 2>/tmp/stderr && \
cat /tmp/stderr > /results/stderr && \
cat /tmp/stdout > /results/stdout && \
chmod 666 /results/std*
COMMANDS
    eos
    puts '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '.blue

    res
  end

end