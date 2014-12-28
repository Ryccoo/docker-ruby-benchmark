require_relative '../config/config'

class BenchmarkController
  def run_benchmarks(options = {})
    default_repeats = (options[:repeats] || BaseConfig::REPETITIONS).to_i

    default_repeats.times do

      BenchUtils.benchmarks.each do |folder_name, script_names|
        script_names.each do |script_name|

          BaseConfig::AVAILABLE_DOCKER_IMAGES.each do |ruby_version, gccs|

            gccs.each do |gcc_v, image_name|
              missing = check_missing_repeats(folder_name, script_name, ruby_version, gcc_v, default_repeats)
              next if missing <= 0
              run_benchmark(folder_name, script_name, ruby_version, gcc_v, image_name)
              BaseConfig::BASE_CONTROLLER.remove_containers
            end

          end
        end
      end
    end
  end

  def check_missing_repeats(folder_name, script_name, ruby_version, gcc_version, default)
    file = BaseConfig.path.join('results', "#{ruby_version}.csv")
    if FileTest.exist? file
      data = File.read file
      found = data.lines.select {|l| l =~ /#{folder_name}\/#{script_name}/ && l =~ /;#{gcc_version};/}.count
      return (default - found)
    else
      return default
    end
  end

  def run_benchmark(folder_name, ruby_script_name, ruby_version, gcc_version, image_name)
    remove_tmp_files

    args = benchmark_args(BaseConfig.path.join("benchmarks/#{folder_name}/"), ruby_script_name)
    runnable_name = "#{ruby_script_name} #{args}"
    begin
      if ENV['BENCH_MEMORY'] == 'true'
        res = BaseConfig::DOCKER_CONTROLLER.run_memory_benchmark(image_name, folder_name, runnable_name)
      else
        res = BaseConfig::DOCKER_CONTROLLER.run_benchmark(image_name, folder_name, runnable_name)
      end
      write_stats(ruby_version, gcc_version, folder_name, runnable_name, stderr, stdout, false)
    rescue CommandRunException => e
      write_stats(ruby_version, gcc_version, folder_name, runnable_name, stderr, stdout, true)
    end
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

  def write_stats(ruby_version, gcc_version, folder_name, benchmark, stats, stdout_str, failed = false)
    puts stats
    stdout_str = stdout_str.ascii_only? ? stdout_str : ' '
    stdout_str = stdout_str[0...100].gsub("\n", ' ').gsub(';', ',') # we get rid of newlines and ';'
    times = stats.split(/\n/).last(20).map{|t| t[0...50] }
    memory = times.find {|t| t =~ /memory/ }
    memory = memory ? memory.gsub(/memory\s*/, '') : nil
    time = times.find {|t| t =~ /real/ }
    time = time ? time.gsub(/real\s*/, '') : nil
    basename = benchmark.gsub(/\.rb.*/, '')
    File.open(BaseConfig.path.join('results', "#{ruby_version}.csv"), 'a') do |f|
      if failed
        f.puts "#{folder_name}/#{benchmark};#{ruby_version};#{gcc_version};#{basename};FAILED;#{Time.now.to_s};#{memory};#{times};#{stdout_str}; "
      else
        f.puts "#{folder_name}/#{benchmark};#{ruby_version};#{gcc_version};#{basename};#{time};#{Time.now.to_s};#{memory};#{times};#{stdout_str}; "
      end
    end

    remove_tmp_files
  end

  def remove_tmp_files
    File.delete BaseConfig.path.join('results','stderr')
    File.delete BaseConfig.path.join('results','stdout')
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