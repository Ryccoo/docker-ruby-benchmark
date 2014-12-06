require_relative '../config/config'

class BenchmarkController
  def run_benchmark_games(options = {})
    default_repeats = options[:repeats] || BaseConfig::REPETITIONS

    BaseConfig::AVAILABLE_DOCKER_IMAGES.each do |k,v|
      BaseConfig::DOCKER_CONTROLLER.test_ruby_version(k,v)
      puts "Running benchmark game in image #{v} with ruby -v #{k}".green
      BenchUtils.benchmark_games.each do |script_name|
        repeats = check_missing_repeats(script_name, k, default_repeats)
        repeats.times do
          benchmark_game(script_name, k, v)
        end
      end
    end
  end

  def check_missing_repeats(script_name, ruby_version, default)
    file = BaseConfig.path.join('results', "#{ruby_version}.csv")
    if FileTest.exist? file
      data = File.read file
      found = data.lines.select {|l| l =~ /#{script_name}/}.count
      return (default - found)
    else
      return default
    end
  end

  def benchmark_game(ruby_script_name, ruby_version, image_name)
    args = benchmark_args(Pathname.new('benchmark-game/benchmarks'), ruby_script_name)
    runnable_name = "#{ruby_script_name} #{args}"
    res = BaseConfig::DOCKER_CONTROLLER.run_benchmark_game(image_name, runnable_name)
    write_stats(ruby_version, runnable_name, stderr, stdout)
  end

  def benchmark_args(path, benchmark)
    basename = benchmark.gsub(/\.rb/, '')
    if File.exists?(path.join("#{basename}.arg"))
      File.open(path.join("#{basename}.arg"), 'r') {|f| f.read }.strip
    elsif File.exists?(path.join("#{basename}.input"))
      "< #{basename}.input"
    end
  end

  private

  def write_stats(ruby_version, benchmark, stats, stdout_str)
    puts stats
    stdout_str = stdout_str.ascii_only? ? stdout_str : ' '
    stdout_str = stdout_str[0...100].gsub("\n", ' ').gsub(';', ',') # we get rid of newlines and ';'
    times = stats.split(/\n/).last(20).map{|t| t[0...50] }
    time = times.find {|t| t =~ /real/ }
    time = time ? time.gsub(/real\s*/, '') : nil
    basename = benchmark.gsub(/\.rb.*/, '')
    File.open(BaseConfig.path.join('results', "#{ruby_version}.csv"), 'a') do |f|
      f.puts "#{benchmark};#{ruby_version};#{basename};#{time};#{Time.now.to_s};#{times};#{stdout_str}; "
    end

    remove_tmp_files
  end

  def remove_tmp_files
    File.delete BaseConfig.path.join('results','stdout')
    File.delete BaseConfig.path.join('results','stderr')
  rescue
    nil
  end

  def stdout
    File.read(BaseConfig.path.join('results','stdout'))
  rescue
    ""
  end

  def stderr
    File.read(BaseConfig.path.join('results','stderr'))
  rescue
    ""
  end
end