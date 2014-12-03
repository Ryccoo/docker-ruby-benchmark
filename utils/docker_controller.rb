require_relative 'bench_utils'

class DockerController

  def test_docker_runnable image_name
    BenchUtils.run_command("docker run #{image_name} echo 'Testing #{image_name}'")
  end

  def run_benchmark_game ruby_version, image_name
    BenchUtils.benchmark_games.each do |game|
      res = BenchUtils.run_command <<-eos
docker run -i -v ${PWD}/results:/results #{image_name} bash -l << COMMANDS
git clone https://github.com/Ryccoo/docker-ruby-benchmark.git repo && \
cd repo && cd benchmark-game && \
touch results.csv && \
ruby run-benchmarks.rb #{ruby_version} #{game} && \
cat results.csv >> /results/#{ruby_version}.csv && \
chmod 666 /results/#{ruby_version}.csv && \
rm results.csv
COMMANDS
      eos

      puts res[:stdout]
    end
    # BenchUtils.run_command <<-eos
    # docker run -i -v ${PWD}/results:/results #{image_name} bash << COMMANDS
    # git clone https://github.com/Ryccoo/docker-ruby-benchmark.git
    # cd docker-ruby-benchmark && cd benchmark-game && ruby run-benchmarks #{ruby_version} && cp results.csv /results/#{ruby_version}.csv
    # COMMANDS
    #     eos
  end

end