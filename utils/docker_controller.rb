require_relative 'bench_utils'

class DockerController

  def test_docker_runnable image_name
    BenchUtils.run_command("docker run #{image_name} echo 'Testing #{image_name}'")
  end

end