require_relative 'bench_utils'

class DockerController

  def test_docker_runnable image_name
    BenchUtils.run_command("docker run #{image_name} echo 'Testing #{image_name}'")
  end

  def run_benchmark_game ruby_version, image_name
    BenchUtils.run_command <<-eos
docker run -i -v ${PWD}/results:/results #{image_name} bash << COMMANDS
cd ruby-benchmark-game && ruby run-benchmarks #{ruby_version} && cp results.csv /results/#{ruby_version}.csv
COMMANDS
    eos
  end

end