require_relative '../config/config'

class ResultsFormatter

  attr_reader :medians, :results, :compact

  def initialize
    @results = Hash.new()
    @medians = Hash.new()
  end

  def parse_available
    BaseConfig::AVAILABLE_DOCKER_IMAGES.keys.each do |version|
      parse_results version
      median_results version
    end
  end

  def parse_results ruby_version
    filename = "#{ruby_version}.csv"
    data = File.read BaseConfig.path.join('results', filename)
    res = data.lines.map do |line|
      cmd, version, test, time, run_date, stderr, stdout = line.split(';')
      {
        command: cmd,
        ruby_version: version,
        benchmark_name: test,
        time: time,
        run_date: run_date,
        stderr: stderr,
        stdout: stdout
      }
    end

    @results[ruby_version] = res

    return res
  rescue
    return []
  end

  def median_results ruby_version
    results = @results[ruby_version]

    return unless results

    group = {}
    results.map {|r| (group[r[:benchmark_name]] ||= []) << r }
    median = group.map do |bench_name, results|
      total_time = results.collect{|r| r[:time].to_f }.inject(:+)
      median_time = total_time / results.count.to_f
      ret = results.first
      ret[:time] = median_time

      ret
    end

    @medians[ruby_version] = median

    return median
  end

  def compact_results
    @compact = {}
    @medians.each do |version, results|
      results.each do |result|
        (@compact[result[:command]] ||= {})[version] = result
      end
    end
  end

  def print_results
    file = File.open(BaseConfig.path.join('results', 'compact.csv'), 'w')

    header = ['benchmark with args'] + @medians.keys
    file.puts header.join(';')

    @compact.each do |test, versions|
      l = Array.new(header.size)
      l[0] = test
      versions.each do |version, result|
        i = header.index version
        l[i] = result[:time]
      end
      file.puts(l.join(';'))
    end

    file.close
  end

end