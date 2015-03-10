require_relative '../config/config'

class BenchmarkController

  def initialize
    @runs = {}
  end

  def run_benchmarks(options = {})
    default_repeats = (options[:repeats] || BaseConfig::REPETITIONS).to_i

    BenchUtils.benchmarks.each do |folder_name, script_names|
      script_names.each do |script_name|

        default_repeats.times do

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

    puts "Checking missing runs of #{script_name} for #{ruby_version} #{gcc_version}" if ENV['VERBOSE']

    return @runs[[folder_name, script_name, ruby_version, gcc_version]] if @runs[[folder_name, script_name, ruby_version, gcc_version]]

    if FileTest.exist? file
      data = File.read file
      found = data.lines.select {|l| l =~ /#{folder_name}\/#{script_name}/ && l =~ /;#{gcc_version};/}.count
      @runs[[folder_name, script_name, ruby_version, gcc_version]] = default - found
      return (default - found)
    else
      @runs[[folder_name, script_name, ruby_version, gcc_version]] = default
      return default
    end
  end

  def run_benchmark(folder_name, ruby_script_name, ruby_version, gcc_version, image_name)
    remove_tmp_files

    args = benchmark_args(BaseConfig.path.join("benchmarks/#{folder_name}/"), ruby_script_name)
    runnable_name = "#{ruby_script_name} #{args}"
    puts BaseConfig::SEPARATOR.blue
    puts "Running benchmark #{ruby_script_name} on #{ruby_version}".green
    begin
      if folder_name == 'custom'
        res = BaseConfig::DOCKER_CONTROLLER.run_custom_benchmark(image_name, folder_name, runnable_name)
      else
        res = BaseConfig::DOCKER_CONTROLLER.run_benchmark(image_name, folder_name, runnable_name)
      end
      write_stats(ruby_version, gcc_version, folder_name, ruby_script_name, runnable_name, stderr, stdout, false)
    rescue CommandRunException => e
      write_stats(ruby_version, gcc_version, folder_name, ruby_script_name, runnable_name, stderr, stdout, true)
    ensure
      puts BaseConfig::SEPARATOR.blue
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

  def write_stats(ruby_version, gcc_version, folder_name, benchmark_without_args, benchmark, stderr_str, stdout_str, failed = false)

    key = [folder_name, benchmark_without_args, ruby_version, gcc_version]

    puts stderr_str
    stdout_str ||= ''
    stdout_str = stdout_str.ascii_only? ? stdout_str : ' '
    stdout_str = folder_name == 'custom' ? stdout_str : stdout_str[0..100]
    stdout_str = stdout_str.gsub("\n", "\\n").gsub(';', ',') # we get rid of newlines and ';'

    times = stderr_str.split(/\n/).last(20).map{|t| t[0...50] }

    memory = times.find {|t| t =~ /memory/ }
    memory = memory ? memory.gsub(/memory\s*/, '') : nil

    memory_total = times.find {|t| t =~ /memory_total/ }
    memory_total = memory_total ? memory_total.gsub(/memory_total\s*/, '') : nil

    time = times.find {|t| t =~ /real/ }
    time = time ? time.gsub(/real\s*/, '') : nil

    basename = benchmark.gsub(/\.rb.*/, '')

    stderr_str ||= ''
    stderr_str = folder_name == 'custom' ? stderr_str : stderr_str[0.100]
    stderr_str = stderr_str.gsub("\n", "\\n").gsub(";", ",")

    File.open(BaseConfig.path.join('results', "#{ruby_version}.csv"), 'a') do |f|
      if failed
        fail_message = BaseConfig.timeout_applied ? 'TIMEOUT' : 'FAILED'
        f.puts "#{folder_name}/#{benchmark};#{ruby_version};#{gcc_version};#{basename};#{fail_message};#{Time.now.to_s};#{stderr_str};#{memory_total};#{times};#{stdout_str};#{stderr_str}"
        @runs[key] -= 1
      else
        f.puts "#{folder_name}/#{benchmark};#{ruby_version};#{gcc_version};#{basename};#{time};#{Time.now.to_s};#{memory};#{memory_total};#{times};#{stdout_str};#{stderr_str}"
        @runs[key] -= 1
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
