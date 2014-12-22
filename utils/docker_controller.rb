require_relative '../config/config'

class DockerController

  def download_docker_image image_name
    BenchUtils.spawn_command("docker pull #{image_name}")
  end

  def test_docker_runnable image_name, cmd
    download_docker_image(image_name) unless check_docker_exists(image_name)
    BenchUtils.run_command("docker run #{image_name} #{cmd}")
  end

  def check_docker_exists image_name
    image, tag = image_name.split(':')
    res = `docker images | grep '#{image}\\s\\+#{tag}' | wc -l`
    if res.strip.to_i == 1
      return true
    end
    return false
  end

  def test_ruby_version ruby_version, image_name
    puts "Testing ruby version: [Should be: #{ruby_version}]".blue
    res = BenchUtils.run_command <<-eos
docker run -i -v ${PWD}/results:/results -v ${PWD}/benchmarks:/benchmarks #{image_name} bash -l << COMMANDS
ruby -v
COMMANDS
    eos

    res
  end

  def run_benchmark image_name, folder, bench_with_args
    puts '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '.blue
    puts "RUNNING BENCHMARK '#{bench_with_args}'".green
    puts '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '.blue
    res = BenchUtils.run_command <<-eos
docker run -i -v ${PWD}/results:/results -v ${PWD}/benchmarks:/benchmarks #{image_name} bash -l << COMMANDS
cd /benchmarks/#{folder} && \
bash -lc "TIMEFORMAT='real %3R'; time ruby #{bench_with_args}" >/tmp/stdout 2>/tmp/stderr && \
cat /tmp/stderr > /results/stderr && \
cat /tmp/stdout > /results/stdout && \
chmod 666 /results/std*
COMMANDS
    eos
    puts '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '.blue

    res
  end

end